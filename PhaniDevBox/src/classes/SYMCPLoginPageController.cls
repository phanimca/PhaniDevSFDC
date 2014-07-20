global class SYMCPLoginPageController{

    global String username {get; set;}
    global String password {get; set;}
    global String startURL{get;set;}
    global String loginURL{get;set;}
    global String useSecure{get;set;}
    global String orgId{get;set;}
    global String portalId{get;set;}
    global String loginType{get;set;}
    global String action{get;set;}
   
   global SYMCPLoginPageController() {
        startURL='/apex/SYMCPHomePage';
        loginURL='';
        useSecure='true';
        orgId='00D90000000I4nD';
        portalId='06090000000Tqr5';
        loginType='3';
        action='loginAction';
    } 

    global PageReference login() {
        //startUrl=Page.SYMCPHomePage.getUrl();  
        System.debug('startUrl.......................'+startUrl);  
        String startUrl1 = System.currentPageReference().getParameters().get('startURL');
        System.debug('User id: ' + username);
        System.debug('password'+password);
        PageReference p=Site.login(username, password, startUrl1);
        
        //p=Page.SYMCPHomePage;
        System.debug('Site login.....................'+p);
        return p;
    }
    
    
    
    global static testMethod void testSYMCPLoginPageController() {
        // Instantiate a new controller with all parameters in the page
        SYMCPLoginPageController controller = new SYMCPLoginPageController();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
                
        System.assertEquals(controller.login(),null);                           
    }    



} // end of class