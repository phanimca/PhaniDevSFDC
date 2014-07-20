trigger AccountBeforeInsert on Account (before insert, before update) {
    
    List<Account> alist=new List<Account>();
    Integer index=0;
    for(Account aa:Trigger.New){
    try{    
        if(aa.AccountNumber==null)
            throw new AccountException('AccountNumber is null');
            //aa.AccountNumber.addError('Account Number should not be null');    
     }catch(AccountException e){
         Case c=new Case();
         c.Subject='Phani-Error ' + index;
         insert c;
         aa.AccountNumber.addError('Account Number should not be null');    

             
     }    
     index++;   
    } // end of for loop
    
    
} // end of trigger