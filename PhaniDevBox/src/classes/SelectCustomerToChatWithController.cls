public class SelectCustomerToChatWithController {
	public static String greetingPartOne = 'Hello, ';
	public static String greetingPartTwo = ' how can I help you?';
	//selected customer's index
	public Integer selectedCustomerIndex {get;set;}
	public String caseId {get;set;}
	
	public class ChatManagerWrapper{
		public Chat_Manager__c customer{get;set;}
		public Integer index {get;set;}
	}	
	public List<ChatManagerWrapper> customersList {
		get{
			if(customersList == null){
			List<Chat_Manager__c> chatManagerList = [Select c.Support_User__c, c.Last_Pinged_Date__c, c.Is_Valid__c, c.Customer_Last_Name__c, 
										c.Customer_First_Name__c, c.Customer_Email_Address__c, c.Case__c From Chat_Manager__c c
										where c.Support_User__c = null AND Customer_Email_Address__c != null];
										
			customersList = convertToWrapper(chatManagerList);
			}
										
			return customersList;		
		}
		set;
	}	
	public PageReference startChatWithCustomer(){		
		System.debug('selectedCustomerIndex= ' + selectedCustomerIndex);
		//check if someone else already started conversation with this customer
		if(selectedCustomerIndex == null)
			return null;
		ChatManagerWrapper selectedCustomer = customersList[selectedCustomerIndex];
		List<Chat_Manager__c> selectedCmList =  [Select c.Support_User__c, c.Last_Pinged_Date__c, c.Is_Valid__c, c.Customer_Last_Name__c, 
										c.Customer_First_Name__c, c.Customer_Email_Address__c, c.Case__c From Chat_Manager__c c
										where c.Support_User__c = null AND Customer_Email_Address__c != null 
										AND Id = :selectedCustomer.customer.Id limit 1 for update];
		//if the user is already chatting with someone else
		if(selectedCmList.size() == 0){
			addError(selectedCustomer.customer.Customer_First_Name__c + ' '  + selectedCustomer.customer.Customer_Last_Name__c +
			' is already chatting with another user');
			return null;
		}
		//if user isn't chatting with anyone
		//update user's record to indicate that he/she is currently chatting with the customer
		List<Chat_Manager__c> chSupportUserList = [Select c.Support_User__c, c.Last_Pinged_Date__c, c.Is_Valid__c, c.Customer_Last_Name__c, 
										c.Customer_First_Name__c, c.Customer_Email_Address__c, c.Case__c From Chat_Manager__c c
										where c.Support_User__c = :UserInfo.getUserId() limit 1];
		
		if(chSupportUserList.size() > 0){
			//create a case
			Case caseRecord = new Case();
			
			caseRecord.Description = 'Customer email address: ' + selectedCustomer.customer.Customer_Email_Address__c +
									 '\nCustomer name: ' + selectedCustomer.customer.Customer_First_Name__c + 
									 ' ' + 	selectedCustomer.customer.Customer_Last_Name__c;
											
			caseRecord.Origin = 'Chat';
			caseRecord.Subject = 'Chat customer issue. ' + selectedCustomer.customer.Customer_Email_Address__c;
			
			insert caseRecord;
			//insert first feed post
			insertFeedPost(caseRecord.Id, greetingPartOne + selectedCustomer.customer.Customer_First_Name__c + ' '  + selectedCustomer.customer.Customer_Last_Name__c +
										greetingPartTwo);
			
			
			chSupportUserList[0].Customer_Email_Address__c = selectedCustomer.customer.Customer_Email_Address__c;
			chSupportUserList[0].Customer_First_Name__c = selectedCustomer.customer.Customer_First_Name__c;
			chSupportUserList[0].Customer_Last_Name__c = selectedCustomer.customer.Customer_Last_Name__c;
			chSupportUserList[0].Case__c = caseRecord.Id;
			
			update chSupportUserList;		
			
			//delete customer's chat manager record
			delete selectedCmList;
			//redirect to chat wizard page
			//PageReference chatPage = Page.ChatWidget;
			//chatPage.getParameters().put('caseId',caseRecord.Id);
			caseId = caseRecord.Id;
			//chatPage.setRedirect(true);
			System.debug('caseId= ' + caseId);
			//return chatPage;
			return null;			
		}
		else{
			addError('You are not signed in to the chat');
			return null;
		}		
		
		return null;
		
	}
	
	private String insertFeedPost(String caseId, String message){
		FeedPost fpost = new FeedPost();
		fpost.ParentId = caseId; 
		fpost.Body = message;
        insert fpost;
        
        return fpost.Id;
	}
	
	public PageReference cancel(){
		
		PageReference homePage = new PageReference('/home/home.jsp');
		homePage.setRedirect(true);
		return homePage;
	}
	 /**
        Adds an error message to the page
    */
    private void addError(String errorMsg){         
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,errorMsg);                               
        ApexPages.addMessage(msg);
    }
    
	private List<ChatManagerWrapper> retrieveCustomersList(){
		if(customersList == null){
			List<Chat_Manager__c> chatManagerList = [Select c.Support_User__c, c.Last_Pinged_Date__c, c.Is_Valid__c, c.Customer_Last_Name__c, 
										c.Customer_First_Name__c, c.Customer_Email_Address__c, c.Case__c From Chat_Manager__c c
										where c.Support_User__c = null AND Customer_Email_Address__c != null];
										
			customersList = convertToWrapper(chatManagerList);
		}
										
		return customersList;
	}
	
	private List<ChatManagerWrapper> convertToWrapper(List<Chat_Manager__c> chatManagerList){
		List<ChatManagerWrapper> wrapperList = new List<ChatManagerWrapper>();
		Integer i=0;
		for(Chat_Manager__c cm: chatManagerList){
			ChatManagerWrapper cmw = new ChatManagerWrapper();
			cmw.customer = cm;
			cmw.index = i++;
			wrapperList.add(cmw);
		}		
		return wrapperList;		
	}

}