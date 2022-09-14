# Event Grid Trigger-Azure-Function 
### Back up keys in an Azure key vault 
This function gets triggered when a new key is created in the source vault and makes a copy of the new key in the destination key vault. 

You can find everything about this project in the following blog post that I wrote.
https://medium.com/@yamchi/how-to-design-an-event-driven-architecture-to-back-up-a-key-from-an-azure-key-vault-using-event-de170940bfce

# Testing:
To test the function, fork and make a clone of this project.
Open the project in VS code and deploy it to the azure function app in your account.

Other elements such as creating key vaults, event grids, and managed identities have been explained in my [blog](https://medium.com/@yamchi/how-to-design-an-event-driven-architecture-to-back-up-a-key-from-an-azure-key-vault-using-event-de170940bfce).


