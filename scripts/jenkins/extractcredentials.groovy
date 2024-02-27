import com.cloudbees.plugins.credentials.CredentialsProvider
import com.cloudbees.plugins.credentials.common.StandardUsernamePasswordCredentials
import com.cloudbees.plugins.credentials.domains.Domain

// Get all credentials domains
def domains = CredentialsProvider.lookupDomains()

// Iterate over each domain
domains.each { domain ->
    println("Domain: ${domain.name}")

    // Get all credentials for the current domain
    def credentials = CredentialsProvider.lookupCredentials(
        StandardUsernamePasswordCredentials.class,
        Jenkins.instance,
        null,
        [domain]
    )

    // Iterate over each credential in the domain
    credentials.each { credential ->
        println("  Credential ID: ${credential.id}")
        println("  Class: ${credential.class}")
        println("  Description: ${credential.description}")
        // Print the username and password if it's a username/password credential
        if (credential instanceof StandardUsernamePasswordCredentials) {
            println("  Username: ${credential.username}")
            println("  Password: ${credential.password}")
        }
    }
}