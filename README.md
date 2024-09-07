

   _____  _____ _____    _____                       
  / ____|/ ____|  __ \  |  __ \                      
 | |  __| |    | |__) | | |  | | ___ _ __ ___   ___  
 | | |_ | |    |  ___/  | |  | |/ _ \ '_ ` _ \ / _ \ 
 | |__| | |____| |      | |__| |  __/ | | | | | (_) |
  \_____|\_____|_|      |_____/ \___|_| |_| |_|\___/ 
                                                     
                                                     
# A project to demonstrate how to deploy an ESC Rest-API as a Function on GCP
## Preambel
The ESC (Entity Similarity Checker) library is, as the name suggests, a software library that you have to integrate into your own software. Apart from a few CLI commands, you cannot use it directly. In this demo project, a simple GCP Cloud Run Function was implemented to show how easy it is to create such a function and, above all, how easy it is to deploy such a function on GCP. The implemented function in this project does not have its own error handling and security etc. It is a demonstration and not a production ready product. It is recommended not to make such Cloud Run Functions directly accessible to the public web and to place them behind a load balancer and a WAF instead.
## Usage
### Just deploy with Terraform
You can use the Terraform script "main.tf" to deploy the function to your GCP environment.
**Prerequisits**
1. You need Terraform and the GCP CLI installed.
2. You need a GCP project with all needed access rigths to deploy a Cloud Run Function, to create a Cloud Storage Bucket and store an object and to set IAM policies.
3. You need a access key as JSON to allow Terraform to access your GCP project. If you use an other login process for Terraform you have to adapt the Terraform file (main.tf).
4. You need curl installed on your machine. If your OS doesn't support the execution of curl command you have to adapt the Terraform file (main.tf) to a local command which allows you to download a binary file from the internet.

**Installation**
1. Download at least the Terraform file "main.tf".
2. Open your terminal and switch to the folder you saved the Terraform file ("main.tf").
3. Execute the following commands:

```bash
terraform init
terraform plan
terraform apply
```

4. Check the outputs from the commands and enter the needed values of the variables: Your GCP project id and the path to your GCP access JSON.
5. If everthing was successful you can call the service using the given URL at the end of the Terraform output.

**Entity names**
This project also provide a second endpoint for getting the similarities of entity names. Feel free to add a second Cloud Run Function to this entry point: OrganisationNameExplanation.

```hcl
resource "google_cloudfunctions2_function" "entity_function" {
  name        = "give-a-function-name"
  location    = var.region
  build_config {
    runtime      = "java17"
    entry_point  = "example.OrganisationNameExplanation"
    source {
      storage_source {
        bucket = "${var.project_id}_${var.bucket_name}"
        object = var.bin_file_name
      }
    }
  }

  service_config {
    available_memory = "256M"
    ingress_settings = "ALLOW_ALL"
    max_instance_count = 5
  }
  
  depends_on = [google_storage_bucket_object.function_source]
}
```

### Build from scratch
If you want to modify the source code of this example then you have to build the assembly yourself:

1. Compile the Scala project with (make sure you are in the right folder):

```bash
sbt assembly
```

2. This creates a single JAR file. Pack it into a zip file. Switch to the target folder where the JAR file is. Make sure you have zip installed:

```bash
zip EscCloudFunctionsExample.zip EscCloudFunctionsExample.jar
```

3. Adapt the Terraform file ("main.tf"). Remove the download part and change the path to the zip file to your local path.





