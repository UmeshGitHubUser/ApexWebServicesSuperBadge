/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ProductZoningServiceTest {

    @TestSetup
    static void setup() {
        // Create Product
        Product2 product = new Product2(Name = 'Test Product', ProductCode = 'TC111', Family = 'TestFamily');
        insert product;
    }

    @IsTest
    static void testGetPermissibleFlyZone() {
        // Test with valid product code and country code
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ProductZoning/';
        req.addParameter('ProductCode', 'TC111');
        req.httpMethod = 'GET';
        req.headers.put('CountryCode', 'US');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        String response = ProductZoningService.getPermissibleFlyZones();
        System.assertEquals('Confirm with the local authorities', response);

        // Test with valid product code and different country code
        req.headers.put('CountryCode', 'DE');
        response = ProductZoningService.getPermissibleFlyZones();
        System.assertEquals('Confirm with the local authorities', response);

        // Test with valid product code but country code not defined
        req.headers.put('CountryCode', 'FR');
        response = ProductZoningService.getPermissibleFlyZones();
        System.assertEquals('Confirm with the local authorities', response);

        // Test with missing product code
        req = new RestRequest();
        req.requestURI = '/services/apexrest/ProductZoning/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        response = ProductZoningService.getPermissibleFlyZones();
        System.assertEquals('ProductCode is missing or doesn\'t exist', response);

        // Test with non-existent product code
        req = new RestRequest();
        req.requestURI = '/services/apexrest/ProductZoning/';
        req.addParameter('ProductCode', '');
        req.httpMethod = 'GET';
        RestContext.request = req;
        response = ProductZoningService.getPermissibleFlyZones();
        System.assertEquals('ProductCode is missing or doesn\'t exist', response);
    }
}