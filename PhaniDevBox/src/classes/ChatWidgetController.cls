public class ChatWidgetController {
	
	public String caseId {get;set;} 
	private String newCaseId;	
	private String latestCommentId;
	private String latestPostId;
	public String myPost {
		get;
		set{ 
			myPost = value;
			System.debug('MYPOST SETTER CALLED= ' + value);
		}
	}
	private String myLatestPost;
	private String customerEmail;
	private String customerFirstName;
	private String customerLastName;
	public static String WAIT_FOR_ASSISTANCE = '<b>Please wait while we find an agent to assist you</b>';
	public String systemMessage;	
	public String userType {get;set;}
	//initialize controller
	public ChatWidgetController(){	
		userType = 'sfdc';
		System.debug('CONSTRUCTOR IS CALLED ' + ApexPages.currentPage().getParameters().get('caseId'));
		//get query string params, if any
		customerEmail = ApexPages.currentPage().getParameters().get('cemail');
		customerFirstName = ApexPages.currentPage().getParameters().get('cfname');
		customerLastName = ApexPages.currentPage().getParameters().get('clname');
		caseId = ApexPages.currentPage().getParameters().get('caseId');
		if(customerEmail != null)
			userType='Guest';
		newCaseId = caseId;
	}	
	public String latestComment {
		get{			
			return retrieveLatestMessage();
		}		
	}	
	public PageReference postMessage(){
		if(caseId != null){
			//get a feed item id for a given case
			CaseFeed c = [Select Id, FeedPostId from CaseFeed where parentId = :caseId order by createddate ASC limit 1];				
			FeedComment fcomment = new FeedComment();
			fcomment.FeedItemId = C.Id;
			fcomment.CommentBody = myPost;
			insert(fcomment);
		}
		return null;
	}
	/**
		method returns latest sales rep's comment OR user's own message (higher priority)
	*/
	private String retrieveLatestMessage(){
		System.debug('caseId= ' + caseId);	
		//check if chat manager record with case and support user is created
		//caseId is null originally for Guest user
		if(caseId == null){
			List<Chat_Manager__c> chatManagerList = [Select c.Support_User__c, c.Last_Pinged_Date__c, c.Is_Valid__c, c.Customer_Last_Name__c, 
											c.Customer_First_Name__c, c.Customer_Email_Address__c, c.Case__c From Chat_Manager__c c
											where c.Support_User__c != null AND Customer_Email_Address__c = :customerEmail 
											AND Case__c != null];	
			if(chatManagerList.size()>0){
				//since record was created support rep is ready to chat with the client
				caseId = chatManagerList[0].Case__c;								 
			}
			else if(systemMessage == null){
				//message below is only show to the Guest
				systemMessage = WAIT_FOR_ASSISTANCE;
				return systemMessage; 
			}
			return null;				
		}
	  	String result;
		//if user/guest posted something  
	  	if(myPost != null && myPost != '' ){
		  	result = '<b>me:</b> ' + myPost;		  	
		  	myPost = null;	
		  	System.debug('returning result= ' + result);		  			  	
		  	return result;
	  	}	
		//else if the counter party posted something as a comment or feed post, there must be at least 2 posts:
		//1 created automatically by sfdc, 2d one posted by the suport rep while joining the chat
	  	List<CaseFeed> l = [SELECT id, FeedPost.Body, FeedPost.Title, FeedPost.ContentData,
	  						CreatedBy.Name,  
           				   (SELECT Id, CommentBody, CreatedDate,
            				     CreatedById, CreatedBy.FirstName, CreatedBy.LastName, CreatedBy.Name
            					 FROM FeedComments ORDER BY CreatedDate DESC LIMIT 10)
			 			    FROM CaseFeed WHERE ParentId = :caseId ORDER BY CreatedDate ASC LIMIT 1];
			
		//now get the latest comment, if any
		List<FeedComment> fc =l[0].FeedComments;		
		if(fc.size() >0){
			//uncomment next line for production, and comment the other one			
			if(latestCommentId == fc[0].Id || UserInfo.getUserId() == fc[0].CreatedById ){
			//if(latestCommentId == fc[0].Id ){				
				return null;
			}
			//set latest comment id						
			latestCommentId = fc[0].Id;			
			result = '<b>' + fc[0].CreatedBy.Name + '</b>: ' + fc[0].CommentBody;
		}//else if there are no comments, get the latest post, i.e the greeting message
		else{			
			if(latestPostId == l[0].Id )
				return null;
			//if it's the guest
			if(userType.equalsIgnoreCase('Guest')){
				result = '<b>' + l[0].CreatedBy.Name + '</b>: ' + l[0].FeedPost.Body;
			}
			else{//else for the support user, display it as 'me:
				result = '<b>me:</b> ' + l[0].FeedPost.Body;
			}
			latestPostId = l[0].Id;
		}
		return result;
	}
	
	public PageReference endChat(){
		//if it's a customer - don't do anything
		if(userType.equalsIgnoreCase('Guest')){
			//clean guest's record, if found			
			List<Chat_Manager__c> chList = [Select c.Support_User__c, c.Last_Pinged_Date__c, c.Is_Valid__c, c.Customer_Last_Name__c, 
											c.Customer_First_Name__c, c.Customer_Email_Address__c, c.Case__c From Chat_Manager__c c
											where c.Support_User__c = null AND c.Customer_Email_Address__c = :customerEmail];
			
			delete chList;	
			return null;
		}
		//if it's a support rep
		List<Chat_Manager__c> chList = getMyChatManagerList();
		for(Chat_Manager__c chm: chList){
			chm.Customer_Email_Address__c = null;
			chm.Customer_First_Name__c = null;
			chm.Customer_Last_Name__c = null;
			chm.Case__c = null;
		}
		update chList;
		
		return null;		
	}	
	private List<Chat_Manager__c> getMyChatManagerList(){
		List<Chat_Manager__c> chList = [Select c.Support_User__c, c.Last_Pinged_Date__c, c.Is_Valid__c, c.Customer_Last_Name__c, 
										c.Customer_First_Name__c, c.Customer_Email_Address__c, c.Case__c From Chat_Manager__c c
										where c.Support_User__c = :UserInfo.getUserId()];
										
		return chList;
	}
}