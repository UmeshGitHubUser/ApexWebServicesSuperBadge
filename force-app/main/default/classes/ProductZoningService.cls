@RestResource(urlMapping='/ProductZoning/*')
global with sharing class ProductZoningService {

    //To test do the following:
    //Goto https://quickstarts.postman.com/guide/connect-postman-to-salesforce/index.html?index=..%2F..index#2
    //follow the instructions to get the token
    //Then rest api call url would be
    //https://girikon123-dev-ed.develop.my.salesforce.com/services/apexrest/ProductZoning?ProductCode=TEST123
    //NOTE: After ? will be mapped to params
    @HttpGet
    global static String getPermissibleFlyZones() {
        String retStr='';
        RestRequest req = RestContext.request;
        //RestResponse res = RestContext.response;
        System.debug('req='+ req);
        System.debug('headers='+ req.headers);
        System.debug('params='+ req.params);

        String cntryCode = req.Headers.get('CountryCode');
        //If CountryCode is not found in the request headers, the implementation 
        //should default the country code to US.
        if(String.isEmpty(cntryCode)){
            cntryCode = 'US';
        }

        //Extract the product code
        String prodCode = req.params.get('ProductCode');
        System.debug('ProductCode ='+ prodCode);
        //If the product code is not found in the request, 
        //the implementation should return an error.
        if(String.isEmpty(prodCode)){
            retStr = 'ProductCode is missing or doesn\'t exist';
        }else{
            List<Product2> prodLst = [SELECT Id, Family, ProductCode FROM Product2 
                               WHERE ProductCode = :prodCode LIMIT 1];    
            
            if(prodLst.isEmpty()){
                retStr = 'ProductCode is missing or doesn\'t exist';
            }else {
                System.debug('prodLst='+prodLst);
                Product2 prod = prodLst[0];
                
                List<Product_Geo_Mapping__mdt> geoMappings = 
                            [SELECT Id, Country_Code__c,Permissible_Fly_Zone__c, Product_Family__c FROM Product_Geo_Mapping__mdt 
                            WHERE Country_Code__c = :cntryCode AND Product_Family__c = :prod.Family LIMIT 1];

                if(geoMappings.isEmpty()){
                    retStr = 'Confirm with the local authorities';
                }else{
                    retStr = geoMappings[0].Permissible_Fly_Zone__c;
                }
            }     
        }

        return retStr;
    }
}