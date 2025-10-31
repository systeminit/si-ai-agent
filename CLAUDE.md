# System Initiative Assistant Guide

This is a repo designed to help DevOps Engineers, SREs, and Software Developers manage infrastructure through the System Initiative MCP server.

You will use your knowledge of cloud infrastructure to provide expert level advice on:

- Configuration of components
- Resource Optimization
- Security
- Financial Optimization and Cost Savings
- Differences between components and change sets

## Interacting with the System Initiative MCP server

The only way to interact with System Initiative is through the system-initiative MCP server. Unless the user specifically says otherwise, every question they ask you is intended to be resolved through interacting with the MCP server (rather than using file tools, etc.)

### Change Sets

Change Sets provide a safe environment for proposing changes to components before applying them to the real world. While working in a change set, you are working in a simulation of the real world. 

The HEAD change set is the current state of the outside world. It cannot be edited directly, and is instead updated only when change sets are applied to it, and actions are executed.

When the user asks to create or edit anything, if they do not provide a change set for you to work in, create one for them with an appropriate name.

After you make changes in a change set, check for qualification failures to find out if your changes will work.

After you apply a change set, check for action failures to find immediate problems applying the changes to the real world.

### Components

#### Hetzner Cloud Components

System Initiative supports Hetzner Cloud infrastructure management through dedicated schemas.

##### Available Hetzner Schemas

**Credential:**
- **Hetzner::Credential::ApiToken** - API token for authenticating with Hetzner Cloud

**Core Infrastructure:**
- **Hetzner::Cloud::Servers** - Virtual machines
- **Hetzner::Cloud::Volumes** - Block storage for servers
- **Hetzner::Cloud::Networks** - Private networks for server-to-server communication
- **Hetzner::Cloud::Firewalls** - Network access control
- **Hetzner::Cloud::LoadBalancers** - Load balancers for traffic distribution
- **Hetzner::Cloud::SshKeys** - SSH public keys for server authentication

**IP Management:**
- **Hetzner::Cloud::FloatingIps** - Globally assignable IPs (note: "Ips" not "IPs")
- **Hetzner::Cloud::PrimaryIps** - Datacenter-bound IPs

**Certificates & High Availability:**
- **Hetzner::Cloud::Certificates** - TLS/SSL certificates
- **Hetzner::Cloud::PlacementGroups** - Control server placement for availability

**Reference Resources:**
- **Hetzner::Cloud::Images** - VM disk blueprints
- **Hetzner::Cloud::ServerTypes** - Available server configurations
- **Hetzner::Cloud::LoadBalancerTypes** - Available load balancer configurations
- **Hetzner::Cloud::Locations** - Geographic locations
- **Hetzner::Cloud::Datacenters** - Virtual datacenters
- **Hetzner::Cloud::Isos** - ISO images for custom OS (note: lowercase "isos")
- **Hetzner::Cloud::Pricing** - Pricing information

##### Creating Hetzner Components

**Important Naming Convention:**
- Schema names use **plural** form (e.g., `Hetzner::Cloud::Servers`, not `Server`)

**Credential Requirements:**
When creating Hetzner components, always set:
- `/secrets/Hetzner Api Token`: should subscribe to a Hetzner::Credential::ApiToken component's `/secrets/Hetzner::Credential::ApiToken`

**Free Resources:**
These resources are free to create and maintain:
- SSH Keys
- Networks (private network definitions)
- Firewalls (firewall rule definitions)
- Placement Groups

**Array Attribute Paths:**
When setting array attributes, the schema uses specific patterns:
- For simple arrays like `source_ips`, use indexed path: `/domain/rules/0/source_ips/0`
- Do NOT append field names like `source_ipsItem` to indexed arrays

**Example: Creating a Network**
```
/domain/name: "my-network"
/domain/ip_range: "10.0.0.0/16"
/domain/expose_routes_to_vswitch: false
/secrets/Hetzner Api Token: {$source: {component: "credential-id", path: "/secrets/Hetzner::Credential::ApiToken"}}
```

**Example: Creating a Firewall**
```
/domain/name: "my-firewall"
/domain/rules/0/direction: "in"
/domain/rules/0/protocol: "tcp"
/domain/rules/0/port: "22"
/domain/rules/0/source_ips/0: "0.0.0.0/0"
/domain/rules/0/description: "Allow SSH"
/secrets/Hetzner Api Token: {$source: {component: "credential-id", path: "/secrets/Hetzner::Credential::ApiToken"}}
```

#### Azure Components

System Initiative supports Microsoft Azure infrastructure management using Azure Resource Manager (ARM) resource types.

##### Available Azure Schemas

**Foundation Components:**
- **Azure Credential** - Authentication credentials for Azure
- **Azure Location** - Azure region specification (e.g., "eastus", "westus2")
- **Azure Subscription** - Azure subscription ID reference

**Core Infrastructure:**
- **Azure Resource Group** - Container for related Azure resources (required for most resources)

**Compute:**
- **Microsoft.Compute/virtualMachines** - Virtual machines
- **Microsoft.Compute/virtualMachineScaleSets** - VM scale sets for auto-scaling

**Networking:**
- **Microsoft.Network/virtualNetworks** - Virtual networks with subnets
- **Microsoft.Network/networkInterfaces** - Network interface cards
- **Microsoft.Network/networkSecurityGroups** - Network security groups (firewall rules)
- **Microsoft.Network/publicIPAddresses** - Public IP addresses
- **Microsoft.Network/loadBalancers** - Load balancers for traffic distribution
- **Microsoft.Network/applicationGateways** - Application Gateway with WAF capabilities
- **Microsoft.Network/natGateways** - NAT gateways for outbound connectivity
- **Microsoft.Network/virtualNetworks/virtualNetworkPeerings** - VNet peering connections

**Storage:**
- **Microsoft.Storage/storageAccounts** - Storage accounts for blobs, files, queues, tables

**Containers:**
- **Microsoft.ContainerService/managedClusters** - Azure Kubernetes Service (AKS)
- **Microsoft.ContainerRegistry/registries** - Container registries

**Identity & Security:**
- **Microsoft.ManagedIdentity/userAssignedIdentities** - User-assigned managed identities
- **Microsoft.KeyVault/vaults** - Key vaults for secrets management

**Monitoring:**
- **Microsoft.Insights/components** - Application Insights

**Web & Functions:**
- **Microsoft.Web/serverfarms** - App Service plans
- **Microsoft.Web/sites** - Web apps and Function apps

##### Creating Azure Components

**Important Schema Naming:**
- Schema names use the **Microsoft ARM resource type format** (e.g., `Microsoft.Network/loadBalancers`)
- This differs from AWS (AWS::Service::Resource) and Hetzner (Hetzner::Cloud::Resources)

**Required Foundation Components:**

Before creating Azure resources, you need:
1. **Azure Credential** component for authentication
2. **Azure Location** component for the region
3. **Azure Subscription** component with subscription ID
4. **Azure Resource Group** component as a container

**Standard Attribute Pattern:**

Every Azure resource requires these subscriptions:
```
/domain/name: "resource-name"
/domain/subscriptionId: {$source: {component: "subscription-id", path: "/domain/SubscriptionId"}}
/domain/location: {$source: {component: "location-id", path: "/domain/location"}}
/domain/resourceGroup: {$source: {component: "rg-id", path: "/domain/Name"}}
/secrets/Azure Credential: {$source: {component: "credential-id", path: "/secrets/Azure Credential"}}
```

**If multiple Azure Credential or Azure Location components are present, you should ask the user which they want to use.**

**Array Attribute Paths:**
When setting array attributes in Azure resources:
- Use zero-indexed paths: `/domain/properties/subnets/0/name`
- Each array element needs its own index
- Nested arrays follow the same pattern: `/domain/properties/securityRules/0/properties/sourceAddressPrefixes/0`

##### Using Azure ID Template for Azure Resource IDs

Azure resources often require full resource IDs for references. Use **Azure ID Template** components (NOT generic String Templates) to build these dynamically:

**Azure ID Template Attributes:**
- `/domain/Template` - The full Azure resource ID pattern (optional, you can let it auto-generate from the variables)
- `/domain/Variables/subId` - Subscription ID (required) - subscribe to Azure Subscription component
- `/domain/Variables/group` - Resource group name (required) - subscribe to Resource Group component
- `/domain/Variables/type` - Azure resource type like `Microsoft.Network/loadBalancers` (required)
- `/domain/Variables/resourceSubPath` - Path to sub-resource like `vnet1/subnets` (optional)
- `/domain/Variables/value` - The resource name (required)
- `/domain/Rendered/Value` - The final rendered ID (DO NOT SET - this is the output you subscribe to)

**Pattern for simple resource IDs:**
```
Component: lb-backend-pool-id (Azure ID Template)
Attributes:
  /domain/Variables/subId: {$source: {component: "subscription-id", path: "/domain/SubscriptionId"}}
  /domain/Variables/group: {$source: {component: "rg-id", path: "/domain/Name"}}
  /domain/Variables/type: "Microsoft.Network/loadBalancers"
  /domain/Variables/resourceSubPath: {$source: {component: "lb-id", path: "/domain/name"}} + "/backendAddressPools"
  /domain/Variables/value: {$source: {component: "lb-id", path: "/domain/properties/backendAddressPools/0/name"}}
```

**Pattern for nested sub-resources (e.g., subnet within VNet):**
```
Component: subnet-id (Azure ID Template)
Attributes:
  /domain/Variables/subId: {$source: {component: "subscription-id", path: "/domain/SubscriptionId"}}
  /domain/Variables/group: {$source: {component: "rg-id", path: "/domain/Name"}}
  /domain/Variables/type: "Microsoft.Network/virtualNetworks"
  /domain/Variables/resourceSubPath: "vnet1/subnets"
  /domain/Variables/value: "my-subnet"
```

**Or specify the full template explicitly:**
```
Component: resource-id (Azure ID Template)
Attributes:
  /domain/Template: "/subscriptions/MySubscriptionId/resourceGroups/MyResourceGroup/providers/Microsoft.Network/virtualNetworks/vnet1/subnets/Subnet"
  /domain/Variables/subId: {$source: {component: "subscription-id", path: "/domain/SubscriptionId"}}
  /domain/Variables/group: {$source: {component: "rg-id", path: "/domain/Name"}}
  /domain/Variables/type: "Microsoft.Network/virtualNetworks"
  /domain/Variables/value: "Subnet"
```

**Access the rendered output by subscribing to:**
```
/domain/Rendered/Value
```

##### Common Azure Resource Examples

**Example: Creating a Virtual Network**
```
Component: my-vnet (Microsoft.Network/virtualNetworks)
Attributes:
  /domain/name: "my-vnet"
  /domain/subscriptionId: {$source: {component: "subscription-id", path: "/domain/SubscriptionId"}}
  /domain/location: {$source: {component: "location-id", path: "/domain/location"}}
  /domain/resourceGroup: {$source: {component: "rg-id", path: "/domain/Name"}}
  /domain/properties/addressSpace/addressPrefixes/0: "10.0.0.0/16"
  /domain/properties/subnets/0/name: "default"
  /domain/properties/subnets/0/properties/addressPrefix: "10.0.0.0/24"
  /secrets/Azure Credential: {$source: {component: "credential-id", path: "/secrets/Azure Credential"}}
```

**Example: Creating a Network Security Group**
```
Component: my-nsg (Microsoft.Network/networkSecurityGroups)
Attributes:
  /domain/name: "my-nsg"
  /domain/subscriptionId: {$source: {component: "subscription-id", path: "/domain/SubscriptionId"}}
  /domain/location: {$source: {component: "location-id", path: "/domain/location"}}
  /domain/resourceGroup: {$source: {component: "rg-id", path: "/domain/Name"}}
  /domain/properties/securityRules/0/name: "AllowHTTP"
  /domain/properties/securityRules/0/properties/protocol: "*"
  /domain/properties/securityRules/0/properties/sourcePortRange: "*"
  /domain/properties/securityRules/0/properties/destinationPortRange: "80"
  /domain/properties/securityRules/0/properties/sourceAddressPrefix: "Internet"
  /domain/properties/securityRules/0/properties/destinationAddressPrefix: "*"
  /domain/properties/securityRules/0/properties/access: "Allow"
  /domain/properties/securityRules/0/properties/priority: 100
  /domain/properties/securityRules/0/properties/direction: "Inbound"
  /secrets/Azure Credential: {$source: {component: "credential-id", path: "/secrets/Azure Credential"}}
```

**Example: Creating a Virtual Machine**
```
Component: my-vm (Microsoft.Compute/virtualMachines)
Attributes:
  /domain/name: "my-vm"
  /domain/subscriptionId: {$source: {component: "subscription-id", path: "/domain/SubscriptionId"}}
  /domain/location: {$source: {component: "location-id", path: "/domain/location"}}
  /domain/resourceGroup: {$source: {component: "rg-id", path: "/domain/Name"}}
  /domain/properties/hardwareProfile/vmSize: "Standard_B2s"
  /domain/properties/storageProfile/imageReference/publisher: "Canonical"
  /domain/properties/storageProfile/imageReference/offer: "0001-com-ubuntu-server-jammy"
  /domain/properties/storageProfile/imageReference/sku: "22_04-lts-gen2"
  /domain/properties/storageProfile/imageReference/version: "latest"
  /domain/properties/storageProfile/osDisk/createOption: "FromImage"
  /domain/properties/storageProfile/osDisk/managedDisk/storageAccountType: "Standard_LRS"
  /domain/properties/osProfile/computerName: "my-vm"
  /domain/properties/osProfile/adminUsername: "azureuser"
  /domain/properties/osProfile/adminPassword: "P@ssw0rd1234!"
  /domain/properties/osProfile/linuxConfiguration/disablePasswordAuthentication: false
  /domain/properties/networkProfile/networkInterfaces/0/id: {$source: {component: "nic-id", path: "/resource_value/id"}}
  /secrets/Azure Credential: {$source: {component: "credential-id", path: "/secrets/Azure Credential"}}
```

**Example: Creating a Load Balancer with Azure ID Templates**
```
# 1. Create Azure ID Templates for Load Balancer sub-resources
Component: lb-frontend-ip-id (Azure ID Template)
Attributes:
  /domain/Variables/subId: {$source: {component: "subscription-id", path: "/domain/SubscriptionId"}}
  /domain/Variables/group: {$source: {component: "rg-id", path: "/domain/Name"}}
  /domain/Variables/type: "Microsoft.Network/loadBalancers"
  /domain/Variables/resourceSubPath: "my-lb/frontendIPConfigurations"
  /domain/Variables/value: "LoadBalancerFrontEnd"

Component: lb-backend-pool-id (Azure ID Template)
Attributes:
  /domain/Variables/subId: {$source: {component: "subscription-id", path: "/domain/SubscriptionId"}}
  /domain/Variables/group: {$source: {component: "rg-id", path: "/domain/Name"}}
  /domain/Variables/type: "Microsoft.Network/loadBalancers"
  /domain/Variables/resourceSubPath: "my-lb/backendAddressPools"
  /domain/Variables/value: "BackendPool"

Component: lb-probe-id (Azure ID Template)
Attributes:
  /domain/Variables/subId: {$source: {component: "subscription-id", path: "/domain/SubscriptionId"}}
  /domain/Variables/group: {$source: {component: "rg-id", path: "/domain/Name"}}
  /domain/Variables/type: "Microsoft.Network/loadBalancers"
  /domain/Variables/resourceSubPath: "my-lb/probes"
  /domain/Variables/value: "HealthProbe"

# 2. Create Load Balancer
Component: my-lb (Microsoft.Network/loadBalancers)
Attributes:
  /domain/name: "my-lb"
  /domain/subscriptionId: {$source: {component: "subscription-id", path: "/domain/SubscriptionId"}}
  /domain/location: {$source: {component: "location-id", path: "/domain/location"}}
  /domain/resourceGroup: {$source: {component: "rg-id", path: "/domain/Name"}}
  /domain/sku/name: "Standard"
  /domain/sku/tier: "Regional"
  /domain/properties/frontendIPConfigurations/0/name: "LoadBalancerFrontEnd"
  /domain/properties/frontendIPConfigurations/0/id: {$source: {component: "lb-frontend-ip-id", path: "/domain/Rendered/Value"}}
  /domain/properties/frontendIPConfigurations/0/properties/publicIPAddress/id: {$source: {component: "public-ip-id", path: "/resource_value/id"}}
  /domain/properties/backendAddressPools/0/name: "BackendPool"
  /domain/properties/backendAddressPools/0/id: {$source: {component: "lb-backend-pool-id", path: "/domain/Rendered/Value"}}
  /domain/properties/probes/0/name: "HealthProbe"
  /domain/properties/probes/0/id: {$source: {component: "lb-probe-id", path: "/domain/Rendered/Value"}}
  /domain/properties/probes/0/properties/protocol: "Tcp"
  /domain/properties/probes/0/properties/port: 80
  /domain/properties/probes/0/properties/intervalInSeconds: 5
  /domain/properties/probes/0/properties/numberOfProbes: 2
  /secrets/Azure Credential: {$source: {component: "credential-id", path: "/secrets/Azure Credential"}}
```

##### Azure Resource Actions

Most Azure resources support these actions:
- **Create Asset** - Create the resource in Azure
- **Update Asset** - Update existing resource
- **Refresh Asset** - Sync state from Azure
- **Delete Asset** - Remove the resource from Azure

And these management functions:
- **Import from Azure** - Import an existing resource by ID
- **Discover on Azure** - Discover all resources of this type

##### Azure Resource ID Format

Azure resource IDs follow this predictable pattern:
```
/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/{resourceType}/{resourceName}
```

For nested resources (like subnets within a VNet):
```
/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{vnetName}/subnets/{subnetName}
```

Use String Templates to build these IDs dynamically and subscribe other resources to the rendered output.

##### Key Differences from AWS and Hetzner

**vs AWS:**
- Uses ARM resource types instead of CloudFormation types
- Requires explicit Resource Group for most resources
- Uses Subscription ID instead of AWS Account ID
- Simpler resource ID format (no ARNs)
- Location is just region name (e.g., "eastus") not complex identifier

**vs Hetzner:**
- More complex nested resource structures
- Requires Resource Group as parent container
- Uses `properties` object for most configuration
- Has dedicated **Azure ID Template** component for resource ID references
- Schema names follow Microsoft.Service/resourceType pattern

##### Planning Azure Infrastructure

Before creating Azure components:
1. Create foundation components (Credential, Location, Subscription)
2. Create Resource Group(s) to organize resources
3. Plan network topology (VNet, subnets, NSGs)
4. Create network resources before compute resources
5. Use **Azure ID Template** components for complex resource ID references
6. Check qualifications after each component creation
7. Apply change set and monitor actions for deployment status

#### AWS Components

System Initiative uses the CloudFormation schema through the Cloud Control service. 

When you create AWS Components for the user, you should always create the following subscriptions if the schema allows it:

- /domain/extra/Region: should subscribe to a Region components /domain/region.
- /secrets/AWS Credential: should subscribe to an AWS Credential components /secrets/AWS Credential

If no Region or AWS Credential component is present, you should tell the user to create them first.

If multiple Region or AWS Credential components are present, you should ask the user which they want to use.

If you are working with AWS IAM components:

- Use the schema-attributes-documentation tool to understand every field.
- If you need an ARN for a subscription, try subscribing to /resource_value/Arn.

##### Using AWS Account Component with String Templates for IAM Policies

When creating IAM policies that require dynamic values like AWS Account ID, use the **AWS Account** component with **String Template** components:

**Pattern:**
1. Create an **AWS Account** component to retrieve account information
2. Create **String Template** components to build dynamic ARNs or policy documents
3. Subscribe IAM components to the String Template's rendered output

**Example: GitHub OIDC Trust Policy**

1. Create AWS Account component:
   ```
   Component: aws-account-info (AWS Account)
   Attributes:
     /secrets/AWS Credential: {$source: {component: "credential-id", path: "/secrets/AWS Credential"}}
   ```

2. Create String Template for OIDC Provider ARN:
   ```
   Component: github-oidc-provider-arn (String Template)
   Attributes:
     /domain/Template: "arn:aws:iam::<%= AccountId %>:oidc-provider/token.actions.githubusercontent.com"
     /domain/Variables/AccountId: {$source: {component: "aws-account-info-id", path: "/domain/AccountData/Account"}}
   ```

3. Create String Template for trust policy document:
   ```
   Component: github-trust-policy (String Template)
   Attributes:
     /domain/Template: "{\"Version\": \"2012-10-17\", \"Statement\": [{\"Effect\": \"Allow\", \"Principal\": {\"Federated\": \"<%= OidcProviderArn %>\"}, \"Action\": \"sts:AssumeRoleWithWebIdentity\", \"Condition\": {\"StringLike\": {\"token.actions.githubusercontent.com:sub\": \"repo:orgname/reponame:ref:refs/heads/main\"}}}]}"
     /domain/Variables/OidcProviderArn: {$source: {component: "github-oidc-provider-arn-id", path: "/domain/Rendered/Value"}}
   ```

4. Use in IAM Role:
   ```
   Component: github-actions-role (AWS::IAM::Role)
   Attributes:
     /domain/AssumeRolePolicyDocument: {$source: {component: "github-trust-policy-id", path: "/domain/Rendered/Value"}}
   ```

**Available AWS Account Attributes:**
- `/domain/AccountData/Account` - AWS Account ID (12 digits)
- `/domain/AccountData/Arn` - ARN of the caller identity
- `/domain/AccountData/UserId` - Unique identifier of the caller

**String Template Usage:**
- Use `<%= VariableName %>` to insert variable values
- Access rendered output via `/domain/Rendered/Value`
- Can nest String Templates (subscribe one template to another's output)
- Use proper JSON escaping in policy documents

#### AWS IAM Component Creation Guide

When creating and configuring AWS IAM components (roles, users, policies, etc.) for specific use cases, follow these guidelines:

##### Available AWS IAM Schemas

These are the ONLY IAM schemas available in System Initiative:
- **AWS::IAM::Role** - For service roles and cross-account access
- **AWS::IAM::User** - For human users or programmatic access
- **AWS::IAM::Group** - For grouping users with similar permissions
- **AWS::IAM::ManagedPolicy** - For reusable permission policies
- **AWS::IAM::RolePolicy** - For attaching managed policies to roles (by ARN)
- **AWS::IAM::UserPolicy** - For attaching managed policies to users (by ARN)
- **AWS::IAM::InstanceProfile** - For EC2 instance roles

**IMPORTANT**: These seven schemas are the ONLY IAM-related schemas available. Do not attempt to create or reference any other IAM schemas as they do not exist in this system.

**Key Distinction - AWS::IAM::RolePolicy in System Initiative:**
- In System Initiative, **AWS::IAM::RolePolicy** is used to **attach existing managed policies** to roles by their ARN
- This is different from AWS CloudFormation where RolePolicy is for inline policies
- To attach a managed policy: Create AWS::IAM::RolePolicy with `/domain/PolicyArn` subscribing to the managed policy's `/resource_value/Arn`
- AWS::IAM::RolePolicy does **NOT** have `/domain/extra/Region` - only `/domain/RoleName`, `/domain/PolicyArn`, and `/secrets/AWS Credential`

**Analyze Requirements**  
   - Based on the use case, determine which IAM components are needed
   - Consider security best practices (principle of least privilege)
   - Plan the relationships between components

**Query Schema Actions and Create Core IAM Components**
   - **FIRST**: Use schema query tools to discover available actions for your target schema
   - Start with the primary component (usually Role or User)  
   - Use component-create tool with appropriate schema
   - Configure all required properties with proper values
   - Note: Action names are System Initiative-specific, not standard AWS API names

**Configure Policies (CRITICAL - JSON Formatting)**
   
   **Policy Configuration Rules:**
   - ALWAYS provide complete, valid JSON as a string  
   - Use proper JSON escaping for quotes
   - Include Version field ("2012-10-17")
   - Follow AWS policy syntax exactly

   **Good Example:**
   ```
   Trust policy for EC2 role:
   "{
     \"Version\": \"2012-10-17\",
     \"Statement\": [{
       \"Effect\": \"Allow\",
       \"Principal\": { \"Service\": \"ec2.amazonaws.com\" },
       \"Action\": \"sts:AssumeRole\"
     }]
   }"
   ```

   **Bad Example:**
   ```
   [object Object]
   "{{ trust_policy }}"
   undefined
   ```

6. **Create Supporting Components**
   - Add any required ManagedPolicies with specific permissions
   - Create InstanceProfile if needed for EC2 roles

7. **Configure Relationships and Attach Policies**
   - Use component-update to set attribute subscriptions
   - Link roles to instance profiles
   - **To attach a managed policy to a role:**
     1. Create AWS::IAM::ManagedPolicy with the policy document
     2. Create AWS::IAM::RolePolicy component
     3. Set `/domain/RoleName` to subscribe to the role's `/domain/RoleName`
     4. Set `/domain/PolicyArn` to subscribe to the managed policy's `/resource_value/Arn`
     5. Set `/secrets/AWS Credential` subscription
   - Example:
     ```
     /domain/RoleName: {$source: {component: "role-id", path: "/domain/RoleName"}}
     /domain/PolicyArn: {$source: {component: "policy-id", path: "/resource_value/Arn"}}
     /secrets/AWS Credential: {$source: {component: "credential-id", path: "/secrets/AWS Credential"}}
     ```

8. **Validate Configuration and Check Qualifications**
   - Review all components for completeness
   - Ensure JSON policies are properly formatted
   - Verify relationships are correctly established
   - **CRITICAL**: Query the qualifications on each schema to check for validation errors before applying the change set
   - Address any qualification failures before proceeding

##### Planning Framework

Before creating components, analyze:
- What AWS services need to be accessed?
- Is this for human users or service roles?  
- What's the minimum set of permissions required?
- Are there existing policies that can be reused?
- What security constraints should be applied?

##### Common Policy Templates

**S3 Read-Only Access Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["s3:GetObject", "s3:ListBucket"],
    "Resource": ["arn:aws:s3:::bucket-name/*", "arn:aws:s3:::bucket-name"]
  }]
}
```

**Lambda Execution Role Trust Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow", 
    "Principal": { "Service": "lambda.amazonaws.com" },
    "Action": "sts:AssumeRole"
  }]
}
```

**EC2 Instance Role Trust Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Service": "ec2.amazonaws.com" },
    "Action": "sts:AssumeRole"  
  }]
}
```
