global with sharing class CredentialVerificationService {

    private static final String NO_RECORD_FOUND = 'No record found';
    private static final String CERT_VALID ='Valid';
    private static final String CERT_NEEDS_RENEWAL = 'Needs Renewal';

    webservice static String verifyCredential(String ctLastName, String certName){
        String result = NO_RECORD_FOUND;
        List<Contact_Certification__c> certLst;
        List<Contact> ctLst;

        System.debug('verifyCredential() called...certName='+ certName +' Last Name='+ctLastName);
        //Query Contact if doesn't exist set to No Record Found
        ctLst = [SELECT Id, LastName FROM Contact 
                            WHERE LastName =:ctLastName LIMIT 1];

        System.debug('ctLst='+ctLst);
        
        if(!ctLst.isEmpty()) {
            certLst = 
                [SELECT Id, Name,isActive__c FROM Contact_Certification__c 
                    WHERE 	(Certification__r.Name =:certName OR Name = :certName) AND Contact__c = :ctLst[0].Id LIMIT 1];
            
            if(!certLst.isEmpty()){
                Contact_Certification__c cert = certLst[0];
                
                result = CERT_NEEDS_RENEWAL;
                if(cert.isActive__c){
                    result = CERT_VALID;
                }
            }
        }

	    System.debug('result='+result);
        return result;
    }
}