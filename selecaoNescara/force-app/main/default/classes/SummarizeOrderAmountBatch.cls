global with sharing class SummarizeOrderAmountBatch implements Database.Batchable<SObject>, Database.StateFul{
    global SummarizeOrderAmountBatch() {} 

    global Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'select Id, Account__c, Product__c, RealizedValue__c from ForecastSummary__c';
        System.debug('query => ' + query);

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext context, List<ForecastSummary__c> scope) {
        List<OrderItem> listOrderItems = [select Id, OrderId, Product2Id, Order.AccountId, Quantity, TotalPrice from OrderItem];
        for (ForecastSummary__c itemForecastSummary : scope) {
            for (OrderItem itemOrderItem : listOrderItems) {
                if (itemForecastSummary.Account__c==itemOrderItem.Order.AccountId && itemForecastSummary.Product__c==itemOrderItem.Product2Id) {
                    if (itemForecastSummary.RealizedValue__c==null) {
                        itemForecastSummary.RealizedValue__c = 0;
                    }
                    itemForecastSummary.RealizedValue__c += itemOrderItem.TotalPrice;
                }
            }
        }
        update scope;
    }

    global void finish(Database.BatchableContext context) {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String> {'janaefernandes89@gmail.com'});
        mail.setSubject('O batch SummarizeOrderAmountBatch foi executado');
            
        mail.setPlainTextBody('O batch SummarizeOrderAmountBatch foi executado hoje: ' + system.today());

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail});
    }
}