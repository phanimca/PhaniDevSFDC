public class SupportManagementConsoleController {
	//5 mins = 3.5 Is_Valid__c
	public static String SINGED_OUT = 'SINGED_OUT';
	public static String SINGED_IN = 'SINGED_IN';
	public static String CUSTOMER_ONLINE = 'CUSTOMER_ONLINE';
	public static String CURRENTLY_CHATTING = 'CURRENTLY_CHATTING';
	public static String ERROR = 'ERROR';
	public static String SUCCESS = 'SUCCESS';	
	public String currentCustomerName {get;set;}
	public String currentlyChattingStatus {get;set;}
	
	//contructor, performs initialization
	public SupportManagementConsoleController(){
		//search for a chat manager record for the user		
	}
	
	public String getMyChatStatus(){
		List<Chat_Manager__c> chList = getMyChatManagerList();
		if(chList.size() == 0)
			return SINGED_OUT;
		if(chList.size() == 1 && chList[0].Customer_Email_Address__c == null){
			//check if a customer is on the line
			if(isCustomerOnTheLine()){
				return CUSTOMER_ONLINE;
			}
			return SINGED_IN;		
		}
		if(chList.size() == 1 && chList[0].Customer_Email_Address__c != null){
			currentCustomerName = chList[0].Customer_First_Name__c + ' ' + chList[0].Customer_Last_Name__c;
			currentlyChattingStatus = 'Currently chatting with ' +  chList[0].Customer_First_Name__c + ' ' + chList[0].Customer_Last_Name__c;
			return CURRENTLY_CHATTING;		
		}
		if(chList.size() > 1)
			return ERROR;
		
		return ERROR;
	}	
	public PageReference signMeInToChat(){
		//create a chat manager record without customer and case information
		Chat_Manager__c chManager = new Chat_Manager__c();
		chManager.Support_User__c = UserInfo.getUserId();		
		insert chManager;
		return null;
	}	
	public PageReference pingChatManagerRecord(){
		List<Chat_Manager__c> chList = getMyChatManagerList();
		for(Chat_Manager__c chManager: chList){
			chManager.Last_Pinged_Date__c = System.now();
		}
		update chList;
				
		return null;
	}
	
	public PageReference stopChatWithCustomer(){
		List<Chat_Manager__c> chList = getMyChatManagerList();
		for(Chat_Manager__c chm: chList){
			chm.Customer_Email_Address__c = null;
			chm.Customer_First_Name__c = null;
			chm.Customer_Last_Name__c = null;
		}
		update chList;		
		return null; 
	}
	//todo: modify the method to only end chat with a specific customer
	public PageReference signMeOutFromChat(){
		List<Chat_Manager__c> chList = getMyChatManagerList();
		delete chList;
		return null; 
	}
	
	public PageReference showCustomerSelectionPage(){		
		return null;		
	}	
	
	private List<Chat_Manager__c> getMyChatManagerList(){
		List<Chat_Manager__c> chList = [Select c.Support_User__c, c.Last_Pinged_Date__c, c.Is_Valid__c, c.Customer_Last_Name__c, 
										c.Customer_First_Name__c, c.Customer_Email_Address__c, c.Case__c From Chat_Manager__c c
										where c.Support_User__c = :UserInfo.getUserId()];
										
		return chList;
	}
	
	private boolean isCustomerOnTheLine(){
		List<Chat_Manager__c> chList = [Select c.Support_User__c, c.Last_Pinged_Date__c, c.Is_Valid__c, c.Customer_Last_Name__c, 
										c.Customer_First_Name__c, c.Customer_Email_Address__c, c.Case__c From Chat_Manager__c c
										where c.Support_User__c = null AND Customer_Email_Address__c != null limit 1];
										
		return (chList.size()>0);
	}

}