data "azurerm_subscription" "current" {}

resource "azurerm_subscription_policy_assignment" "azpolicy-addon-enabled-aks" {
  name                 = "azpolicy-to-aks"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/0a15ec92-a229-4763-bb14-0ea34a568f8d"
  subscription_id      = data.azurerm_subscription.current.id
  display_name         = "Azure Policy Add-on for Kubernetes service (AKS) should be installed and enabled on your clusters - TF"

  parameters = <<PARAMETERS
        {
            "effect": {
                "value" : "Audit"
            }
        }
        PARAMETERS
}

resource "azurerm_subscription_policy_assignment" "azpolicy-addon-deploy-aks" {
  name                 = "azpolicy-deploy-aks"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a8eff44f-8c92-45c3-a3fb-9880802d67a7"
  subscription_id      = data.azurerm_subscription.current.id
  display_name         = "Deploy Azure Policy Add-on to Azure Kubernetes Service clusters - TF"
  location             = var.resources_rg_location

  parameters = jsonencode({
    "effect" : {
      "value" : "Disabled",
    },
  })
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_subscription_policy_assignment" "k8s-secbaseline" {
  name                 = "k8s-secbaseline"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/a8640138-9b0a-4a28-b8cb-1666c838647d"
  subscription_id      = data.azurerm_subscription.current.id
  display_name         = "Kubernetes cluster pod security baseline standards for Linux-based workloads - TF"

  parameters = jsonencode({
    "effect" : {
      "value" : "audit",
    }
    "excludedNamespaces" : {
      "value" : [
        "kube-system",
        "gatekeeper-system",
        "azure-arc",
        "argocd",
        "cert-manager",
        "ingress",
        "monitoring",
        "flux-system",
        "cert-manager"
      ]
    }
  })
}

resource "azurerm_policy_definition" "aks-add-support" {
  name         = "aks-add-support"
  display_name = "Enforce AKS aad support"
  policy_type  = "Custom"
  mode         = "All"

  policy_rule = <<POLICY_RULE
    {
      "if": {
        "allOf": [
          {
            "equals": "Microsoft.ContainerService/managedClusters",
            "field": "type"
          },
          {
            "exists": false,
            "field": "Microsoft.ContainerService/managedClusters/aadProfile"
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]"
      }
    }
POLICY_RULE

  parameters = <<PARAMETERS
    {
      "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "Enable or disable the execution of the policy"
        },
        "allowedValues": [
          "Audit",
          "Deny",
          "Disabled"
        ],
        "defaultValue": "Deny"
      }
  }
PARAMETERS

}

resource "azurerm_subscription_policy_assignment" "aks-add-support" {
  name                 = "aks-add-support"
  policy_definition_id = azurerm_policy_definition.aks-add-support.id
  subscription_id      = data.azurerm_subscription.current.id
  display_name         = "Enforce AKS aad support - TF"

  parameters = <<PARAMETERS
        {
            "effect": {
                "value" : "Audit"
            }
        }
        PARAMETERS
}

resource "azurerm_subscription_policy_assignment" "no-local-accounts" {
  name                 = "no-local-accounts"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/993c2fcd-2b29-49d2-9eb0-df2c3a730c32"
  subscription_id      = data.azurerm_subscription.current.id
  display_name         = "Azure Kubernetes Service Clusters should have local authentication methods disabled - TF"

  parameters = <<PARAMETERS
        {
            "effect": {
                "value" : "Audit"
            }
        }
        PARAMETERS
}

resource "azurerm_subscription_policy_assignment" "k8s-allowed-capabilities" {
  name                 = "k8s-allowed-capabilities"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/c26596ff-4d70-4e6a-9a30-c2506bd2f80c"
  subscription_id      = data.azurerm_subscription.current.id
  display_name         = "Kubernetes cluster containers should only use allowed capabilities - TF"

  parameters = jsonencode({
    "effect" : {
      "value" : "audit",
    },
    "requiredDropCapabilities" : {
      "value" : [
        "NET_RAW"
      ],
    },
    "excludedNamespaces" : {
      "value" : [
        "kube-system",
        "gatekeeper-system",
        "azure-arc",
        "argocd",
        "cert-manager",
        "ingress",
        "monitoring",
        "flux-system",
        "cert-manager"
      ]
    }
  })
}

resource "azurerm_subscription_policy_assignment" "k8s-no-default-ns" {
  name                 = "k8s-no-default-ns"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/9f061a12-e40d-4183-a00e-171812443373"
  subscription_id      = data.azurerm_subscription.current.id
  display_name         = "Kubernetes clusters should not use the default namespace - TF"

  parameters = jsonencode({
    "effect" : {
      "value" : "audit",
    },
    "namespaces" : {
      "value" : ["default"]
    },
    "excludedNamespaces" : {
      "value" : [
        "kube-system",
        "gatekeeper-system",
        "azure-arc",
        "argocd",
        "cert-manager",
        "ingress",
        "monitoring",
        "flux-system",
        "cert-manager"
      ]
    }
  })
}

resource "azurerm_subscription_policy_assignment" "k8s-no-external-lb" {
  name                 = "k8s-no-external-lb"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/3fc4dc25-5baf-40d8-9b05-7fe74c1bc64e"
  subscription_id      = data.azurerm_subscription.current.id
  display_name         = "Kubernetes clusters should use internal load balancers - TF"

  parameters = jsonencode({
    "effect" : {
      "value" : "audit",
    },
    "excludedNamespaces" : {
      "value" : [
        "kube-system",
        "gatekeeper-system",
        "azure-arc",
        "argocd",
        "cert-manager",
        "ingress",
        "monitoring",
        "flux-system",
        "cert-manager"
      ]
    }
  })
}

resource "azurerm_subscription_policy_assignment" "k8s-allowlist-ip" {
  name                 = "k8s-allowlist-ip"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/d46c275d-1680-448d-b2ec-e495a3b6cc89"
  subscription_id      = data.azurerm_subscription.current.id
  display_name         = "Kubernetes cluster services should only use allowed external IPs - TF"

  parameters = jsonencode({
    "effect" : {
      "value" : "audit",
    },
    "allowedExternalIPs" : {
      "value" : []
    }
    "excludedNamespaces" : {
      "value" : [
        "kube-system",
        "gatekeeper-system",
        "azure-arc",
        "argocd",
        "cert-manager",
        "ingress",
        "monitoring",
        "flux-system",
        "cert-manager"
      ]
    }
  })
}

resource "azurerm_subscription_policy_assignment" "k8s-allowed-ports" {
  name                 = "k8s-allowed-ports"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/233a2a17-77ca-4fb1-9b6b-69223d272a44"
  subscription_id      = data.azurerm_subscription.current.id
  display_name         = "Kubernetes cluster services should listen only on allowed ports - TF"

  parameters = jsonencode({
    "effect" : {
      "value" : "audit",
    },
    "allowedServicePortsList" : {
      "value" : ["443"]
    }
    "excludedNamespaces" : {
      "value" : [
        "kube-system",
        "gatekeeper-system",
        "azure-arc",
        "argocd",
        "cert-manager",
        "ingress",
        "monitoring",
        "flux-system",
        "cert-manager"
      ]
    }
  })
}
