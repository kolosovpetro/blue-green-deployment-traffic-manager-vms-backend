# Blue-Green Deployment using Azure Traffic Manager

This repository demonstrates a **Blue-Green deployment strategy** using Azure infrastructure and Azure Traffic Manager for traffic routing.

---

## 🚀 Overview

The solution provisions two independent environments:

- **Blue** (current production)
- **Green** (new version)

Traffic is routed via Azure Traffic Manager, allowing controlled switching between environments.

---

## 🏗️ Provision Infrastructure

Run the following commands:

```bash
terraform init -backend-config="azure.sas.conf" -reconfigure -upgrade
terraform plan -out main.tfplan -lock=false
terraform apply -lock=false "main.tfplan"
```

Deploy sample applications:

```powershell
.\Deploy-Blue-Page.ps1
.\Deploy-Green-Page.ps1
```

---

## 🔄 Switch Traffic (Blue ↔ Green)

Switch active environment using scripts:

```powershell
.\Switch-To-Blue.ps1
.\Switch-To-Green.ps1
```

These scripts update endpoint priority in Azure Traffic Manager.

---

## ⚙️ Traffic Routing Modes

Azure Traffic Manager supports two routing strategies:

### 🔵 Priority (Blue-Green / Failover)

- Only **one endpoint is active**
- Lower number = higher priority
- Example:
  - Blue = 1 (active)
  - Green = 2 (standby)

Failover behavior:
- If priority `1` is healthy → receives all traffic
- If unhealthy → traffic goes to `2`, then `3`, etc.

✔ Best for:
- Blue-Green deployments  
- Instant rollback  

---

### 🟢 Weighted (Canary / Gradual rollout)

- Traffic is **distributed proportionally**
- Values are **relative**, not fixed (do NOT need to sum to 1000)

Examples:

- 500 / 500 → 50% / 50%  
- 1000 / 1 → ~99.9% / ~0.1%  
- 300 / 700 → 30% / 70%  

✔ Best for:
- Canary releases  
- Gradual traffic shifting  
- A/B testing  

---

## ⚖️ Pros and Cons

### ✅ Pros

- Zero-downtime deployments  
- Easy rollback (especially with Priority mode)  
- Supports both canary and blue-green strategies  
- Fully automated via Terraform + CLI/PowerShell  

### ❌ Cons

- DNS-based routing → **not instant** (TTL delay)  
- Requires Public IPs with DNS names for endpoints  
- Weighted routing is probabilistic (not exact per request)  

---

## 🧠 Key Notes

- Traffic Manager is **DNS-based**, not a reverse proxy  
- Clients connect directly to resolved endpoints  
- Health checks determine endpoint availability  
- Only one routing method is active at a time:
  - `Priority` OR `Weighted`

---

## 💡 Recommendations

- Use **Priority** for clean Blue-Green deployments  
- Use **Weighted** for safe canary rollouts  
- Combine both in CI/CD:
  1. Start with Weighted (gradual rollout)
  2. Finish with full switch (Priority or 100% weight)

---

## 📌 Future Improvements

- Add automated canary progression (1% → 10% → 50% → 100%)  
- Integrate with Azure DevOps pipelines  
- Add monitoring/alerts for health probes  
- Support multi-region failover  

---

## 📝 Comments

- `Weighted` → controls **traffic distribution**
- `Priority` → controls **failover order**
- Priority values must be **unique per endpoint**
- Lower priority number = higher preference

---

## 📎 References

- Azure Traffic Manager documentation  
- Terraform Azure Provider (`azurerm_traffic_manager_*`)  
