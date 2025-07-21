@RestResource(urlMapping='/lost')
global with sharing class AssetService {
    private static final String NO_DEVICE_FOUND = 'No device found.';
    private static final String CLAIM_ALREADY_FILED = ' already filed.'; // add claim number to this is string
    private static final String NO_COVERAGE = 'No coverage. Asset status adjusted to Lost.';

    @HttpPost
    global static String reportLostDevice (String assetIdentifier ) {

        Boolean exitLoop = false;
        String retStr = '';
        List<Claim__c> claimsLst,newClaimsLst;
        List<Insurance__c> insurancesLst;

        System.debug('reportLostDevice called...');
        //As the Asset Identifier in unique, there would be only one asset returned if exists
        List<Asset> assetsLst = [SELECT Id, Name, Asset_Identifier__c, Status,ContactId FROM Asset 
                                    WHERE Asset_Identifier__c = :assetIdentifier];

        System.debug('assestsLst = '+ assetsLst);
        if(!exitLoop && assetsLst.isEmpty()) {
            System.debug('Asset List is empty');
            retStr = NO_DEVICE_FOUND;
            exitLoop = true;
        }

        //Extract the corresponding insurance
        if(!exitLoop){
            insurancesLst = [SELECT Id, Asset__c FROM Insurance__c WHERE 
                            Asset__c = :assetsLst[0].Id AND Coverage__c ='Comprehensive' AND 
                            Active__c = true LIMIT 1];
            System.debug('insurancesLst='+ insurancesLst);
            if(insurancesLst.isEmpty()) {
                retStr = NO_COVERAGE;
                exitLoop = true;
                assetsLst[0].Status = 'Lost';
                update assetsLst[0];
                System.debug('Insurance List is empty');
            }
        }

        //Check if there is already an existing claim for the insured lost device, if yes
        //return corresponding error messages else create a new claim and return success message
        if(!exitLoop) {
            claimsLst = [SELECT Id,Name FROM Claim__c 
                                WHERE Insurance__c = :insurancesLst[0].Id AND Type__c = 'Loss' LIMIT 1];       
            exitLoop = true;
            //Update the asset to Lost
            assetsLst[0].Status = 'Lost';
            update assetsLst[0];
            
            if(claimsLst.size() > 0) {
                System.debug('Claim List is ='+claimsLst);
                retStr = claimsLst[0].Name + CLAIM_ALREADY_FILED;       
            }else{
                    Claim__c claim = new Claim__c();
                    claim.Insurance__c = insurancesLst[0].Id;
                    claim.Status__c = 'New';
                    claim.Contact__c = assetsLst[0].ContactId;
                    claim.Type__c = 'Loss';
                    claim.Asset__c = assetsLst[0].Id;
                
                	try{
                    insert claim;
                	}catch(DmlException e) {
    					System.debug('The following exception has occurred: ' + e.getMessage());
					}

                    //For auto number fields, query again to after insert to get its value
                    newClaimsLst = [SELECT Id,Name FROM Claim__c 
                                    WHERE Insurance__c = :insurancesLst[0].Id AND Type__c = 'Loss' AND Asset__c = :assetsLst[0].Id LIMIT 1 ];                
                	System.debug('Inserted claim, claim='+newClaimsLst[0]);
                	System.debug('Auto Number ='+ newClaimsLst[0].Name);
                    System.debug('Claim is inserted');
                    retStr = newClaimsLst[0].Name;
            }
        }

        System.debug('return str='+ retStr);
        return retStr;
    }
}