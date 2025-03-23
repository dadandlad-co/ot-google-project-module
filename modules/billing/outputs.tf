output "billing_account_admins" {
  description = "List of billing admins."
  value       = var.billing_admins
}

output "billing_account_budget_id" {
  description = "Resource name of the budget, if enabled."
  value       = var.enable_billing_budget ? google_billing_budget.billing_account_budget[0].id : null
}

output "billing_account_budget_name" {
  description = "The name of the billing account budget, if enabled."
  value       = var.enable_billing_budget ? google_billing_budget.billing_account_budget[0].name : null
}

output "billing_account_cost_managers" {
  description = "List of billing cost managers."
  value       = var.billing_cost_managers
}

output "billing_account_id" {
  description = "The ID of the billing account."
  value       = var.billing_account_id
}

output "billing_account_project_creators" {
  description = "List of billing project creators."
  value       = var.billing_project_creators
}

output "billing_account_users" {
  description = "List of billing users."
  value       = var.billing_users
}

output "billing_account_viewers" {
  description = "List of billing viewers."
  value       = var.billing_viewers
}

output "billing_budget_amount" {
  description = "The amount of the budget, if enabled."
  value       = var.enable_billing_budget ? var.budget_amount : null
}

output "billing_budget_thresholds" {
  description = "The alert thresholds of the budget, if enabled."
  value       = var.enable_billing_budget ? var.budget_alert_spend_thresholds : null
}