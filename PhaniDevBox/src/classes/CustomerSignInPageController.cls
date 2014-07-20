public class CustomerSignInPageController {
	public Chat_Manager__c signInInfo {
		get{
	    	if(signInInfo == null)
	    		signInInfo = new Chat_Manager__c();	    	
	    	return signInInfo;
			} 
	   	set;
	}	
	public boolean showEntryPane {get;set;}	
	public PageReference showDataEntryPane(){
		showEntryPane=true;
		return null;
	}	
	public String chatWidgetUrl {get;set;}	   	
	public PageReference saveSignInInfo(){
		//check if anyone is singed in to chat
		List<Chat_Manager__c> validChList = getValidChatManagerList();
		if(validChlist.size() ==0){
			addWarning('Unfortunately all Support Representatives are busy. Please try again later');
			chatWidgetUrl = null;
			return null;
		}		
		
		insert signInInfo;		
		chatWidgetUrl = '/apex/ChatWidget?' + 'cemail=' +  EncodingUtil.urlEncode(signInInfo.Customer_Email_Address__c, 'UTF-8') + 
						'&cfname=' + EncodingUtil.urlEncode(signInInfo.Customer_First_Name__c, 'UTF-8') +
						'&clname=' + EncodingUtil.urlEncode(signInInfo.Customer_Last_Name__c, 'UTF-8');
		
		signInInfo = null;
		return null;
	}
	
	private List<Chat_Manager__c> getValidChatManagerList(){
		List<Chat_Manager__c> chList = [Select c.Support_User__c, c.Last_Pinged_Date__c, c.Is_Valid__c, c.Customer_Last_Name__c, 
										c.Customer_First_Name__c, c.Customer_Email_Address__c, c.Case__c From Chat_Manager__c c
										where c.Is_Valid__c > 0];
										
		return chList;
	}
	
	private void addWarning(String errorMsg){         
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING,errorMsg);                               
        ApexPages.addMessage(msg);
    }
 
}