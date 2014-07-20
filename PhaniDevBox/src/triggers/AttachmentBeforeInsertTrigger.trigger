trigger AttachmentBeforeInsertTrigger on Attachment (before insert) {
	for(Attachment a:Trigger.New){
		System.debug(' before trigger +++++++++++++: ' + a.IsPrivate);
		a.IsPrivate=true;
		
		System.debug(' aftter trigger +++++++++++++: ' + a.IsPrivate);
		
		
	}
}