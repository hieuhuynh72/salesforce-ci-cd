/*
* Skedulo global standard response for all services.
*
*/

global class skedResponse {
    
    public boolean success      {get;set;}
    public string  message      {get;set{
            message = value;
            if( message.contains('INACTIVE_OWNER_OR_USER,') ) message = message.substringBetween('INACTIVE_OWNER_OR_USER,', ':');           
        }}
    public string  devMessage   {get;set;}
    public object  data         {get;set;}
    
    /*
    * contructor
    */
    public skedResponse() {
        this.success = false;
        this.message = '';
        this.data = null;
    }
    
    /*
    * methods go here
    */

    public void getErrorMessage(Exception ex){
        this.devMessage = ex.getStackTraceString();
        this.message    = ex.getMessage();
    }
}