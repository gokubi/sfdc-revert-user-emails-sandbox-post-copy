/**
 * When sandboxes refresh, all users' email addresses have @example.com appended to them.
 * This is a safety feature to prevent unexpected or unwanted emails to be sent from sandbox to users.
 * This class reverts all active sys admin users' email addresses by removing the @example.com.
 * https://help.salesforce.com/HTViewSolution?id=000193090&language=en_US
 */
/*
MIT License

Copyright (c) 2016 Doug Ayers

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
public with sharing class RevertUserEmailsBatchable implements Database.Batchable<SObject> {

    public Database.QueryLocator start( Database.BatchableContext context ) {
	    List<Profile> p = [SELECT id FROM Profile WHERE name = 'System Administrator' LIMIT 1 ];
        string profileId = '';
        if(p.size()>0){
            profileId = p[0].id;
        }
        return Database.getQueryLocator( 'SELECT id, email FROM User WHERE isActive = true AND ProfileId = :profileId' );
    }

    public void execute( Database.BatchableContext context, List<User> users ) {

        for ( User u : users ) {

            System.debug( 'user sandbox email: ' + u.email );

            u.email = u.email.replace('@example.com', '').replace('=', '@');

            System.debug( 'user reverted email: ' + u.email );

        }

        update users;

    }

    public void finish( Database.BatchableContext context ) {

    }

}