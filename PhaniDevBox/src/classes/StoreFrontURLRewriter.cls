global class StoreFrontURLRewriter implements Site.URLRewriter{

   global pageReference mapRequestUrl(PageReference pf){
    
        PageReference p=new PageReference('https://ap1.salesforce.com/secur/login_portal.jsp?orgId=00D90000000I4nD&portalId=06090000000Tqr5');
        return p;
    }
    
   global List<pageReference> generateUrlFor(List<pageReference> pf){
     return null;
    } 

} // end of class