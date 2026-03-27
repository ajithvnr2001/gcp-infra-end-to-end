# cost/budget-alerts.tf
# GCP Budget alerts — get email/Slack when spend crosses thresholds
# Add this to your terraform/envs/prod/main.tf or apply separately

resource "google_billing_budget" "ecommerce_budget" {
  billing_account = var.billing_account_id
  display_name    = "Ecommerce Platform Monthly Budget"

  budget_filter {
    projects = ["projects/${var.project_id}"]
    services = [
      "services/95FF-2EF5-5EA1",   # Kubernetes Engine
      "services/95FF-2EF5-5EA1",   # Cloud SQL
      "services/95FF-2EF5-5EA1",   # Cloud Storage
    ]
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = "500"    # $500/month budget
    }
  }

  # Alert at 50%, 80%, 100%, 120% of budget
  threshold_rules {
    threshold_percent = 0.5
    spend_basis       = "CURRENT_SPEND"
  }
  threshold_rules {
    threshold_percent = 0.8
    spend_basis       = "CURRENT_SPEND"
  }
  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "CURRENT_SPEND"
  }
  threshold_rules {
    threshold_percent = 1.2
    spend_basis       = "FORECASTED_SPEND"   # alert if projected to exceed
  }

  all_updates_rule {
    monitoring_notification_channels = [
      google_monitoring_notification_channel.budget_email.id
    ]
    disable_default_iam_recipients = false
  }
}

resource "google_monitoring_notification_channel" "budget_email" {
  display_name = "Budget Alert Email"
  type         = "email"
  labels = {
    email_address = "ajithvnr2001@gmail.com"
  }
}
