const grid = document.querySelector("#service-grid");
const message = document.querySelector("#catalog-message");
const search = document.querySelector("#search");
const serviceCount = document.querySelector("#service-count");
const teamCount = document.querySelector("#team-count");
const dialog = document.querySelector("#validation-dialog");
const result = document.querySelector("#form-result");
let services = [];

function renderCatalog(query = "") {
  const term = query.trim().toLowerCase();
  const visible = services.filter((service) => [service.name, service.owner, ...service.tags].join(" ").toLowerCase().includes(term));
  grid.replaceChildren(...visible.map((service) => {
    const card = document.createElement("article");
    card.className = "service-card";
    card.innerHTML = `<p class="owner">${service.owner}</p><h3>${service.name}</h3><p>${service.description}</p><div class="tags">${service.tags.map((tag) => `<span>${tag}</span>`).join("")}</div>`;
    return card;
  }));
  message.textContent = visible.length ? "" : "No services match that search.";
}

async function loadCatalog() {
  try {
    const response = await fetch("/api/v1/services");
    if (!response.ok) throw new Error("Catalog request failed");
    const data = await response.json();
    services = data.services;
    serviceCount.textContent = data.count;
    teamCount.textContent = new Set(services.map((service) => service.owner)).size;
    message.textContent = "";
    renderCatalog();
  } catch (_) {
    message.textContent = "The catalog is temporarily unavailable. Please try again shortly.";
  }
}

search.addEventListener("input", (event) => renderCatalog(event.target.value));
document.querySelector("[data-open-form]").addEventListener("click", () => dialog.showModal());
document.querySelector("[data-close-form]").addEventListener("click", () => dialog.close());

document.querySelector("#validation-form").addEventListener("submit", async (event) => {
  event.preventDefault();
  const form = new FormData(event.currentTarget);
  const payload = Object.fromEntries(form.entries());
  payload.tags = payload.tags ? payload.tags.split(",").map((tag) => tag.trim()).filter(Boolean) : [];
  result.textContent = "Validating…";
  try {
    const response = await fetch("/api/v1/services/validate", {method: "POST", headers: {"Content-Type": "application/json"}, body: JSON.stringify(payload)});
    const data = await response.json();
    result.textContent = data.valid ? "Looks good — this service definition is valid." : Object.entries(data.errors).map(([field, error]) => `${field}: ${error}`).join(" ");
    result.className = `form-result ${data.valid ? "success" : "error"}`;
  } catch (_) {
    result.textContent = "Unable to validate right now. Please try again.";
    result.className = "form-result error";
  }
});

loadCatalog();
