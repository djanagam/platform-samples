import com.cloudbees.plugins.credentials.CredentialsProvider
import com.cloudbees.plugins.credentials.domains.Domain
import jenkins.model.Jenkins

// Function to push all credentials to attached controllers
def pushAllCredentialsToControllers() {
    def jenkins = Jenkins.getInstance()
    
    // Get all attached controllers
    def controllers = jenkins.getNodes().findAll { it -> it.getComputer() != null }

    controllers.each { controller ->
        def controllerJenkins = controller.toComputer().getChannel().call { Jenkins.getInstance() }
        if (controllerJenkins != null) {
            // Get all credentials from CJOC
            CredentialsProvider.lookupCredentials(
                com.cloudbees.plugins.credentials.common.StandardCredentials.class,
                jenkins,
                null,
                null
            ).each { credential ->
                // Push credential to the controller
                println("Pushing credential ${credential.id} to ${controllerJenkins.getDisplayName()}")
                CredentialsProvider.track(controllerJenkins, credential)
            }
        }
    }
}

// Example usage: pushAllCredentialsToControllers()
pushAllCredentialsToControllers()