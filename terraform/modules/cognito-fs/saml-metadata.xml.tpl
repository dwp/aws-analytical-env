<EntityDescriptor ID="_c9b49342-b29c-4701-a36f-596922d4e3c3" entityID="http://dataworks.com/adfs/services/trust" xmlns="urn:oasis:names:tc:SAML:2.0:metadata">
    <ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
        <ds:SignedInfo>
            <ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#" />
            <ds:SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256" />
            <ds:Reference URI="#_c9b49342-b29c-4701-a36f-596922d4e3c3">
                <ds:Transforms>
                    <ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" />
                    <ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#" />
                </ds:Transforms>
                <ds:DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256" />
                <ds:DigestValue>zwZR3OIfmXCrtVcpBnr/iMdUSoLIidgLUts12chg5FQ=</ds:DigestValue>
            </ds:Reference>
        </ds:SignedInfo>
        <ds:SignatureValue>Fw6EIJf4ToqsAYGahWOH3qZsGMf6MrEUE4KrSL6SaEn6DlgBt2+b0YObekdtd5qmWxOpXy5HE3TD6vQYdlf0N1c6TvEY8mte8kgEliz+iKWEcuDQq+v9lucDURXEASre8K/LHbdEpjDMZWbGv6WPA8MN2mB/BvHeCXugu0wzL5nL2U8K9A+Q7LpasAF5s5tFkAdGHgPBzeJ3zssM/4GIXe0pkfVYnEE1wuQATil5WaxENmpm0ZmaDD3oN/Rg32MDuW/Y4cd+z9dXatCNy4Se2SM1DBjxx/Fna+mzveALrB4bmTl8wpyLX6Y6J5Kb6G/uZThJt7JwbJi8UaBOqWJRrg==</ds:SignatureValue>
        <KeyInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
            <X509Data>
                <X509Certificate>MIIC1jCCAb6gAwIBAgIQO4dczEh1Gp1FW6B50JVlAzANBgkqhkiG9w0BAQsFADAnMSUwIwYDVQQDExxBREZTIFNpZ25pbmcgLSBkYXRhd29ya3MuY29tMB4XDTIwMDMxMDE1NTMwOFoXDTIxMDMxMDE1NTMwOFowJzElMCMGA1UEAxMcQURGUyBTaWduaW5nIC0gZGF0YXdvcmtzLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKw6nn1oJ7GbgmtSn8qSILRJlmyGG+MJb+4NQ3NfsTadspj3u1GTi4yls/MydhaWe/+ow3VgudJXRB0uoWy3+mez/4u1bM9SpRAHKbjM/qbbrUAKK0wIpe0+37kQRrUUUbOzo48sCsoHcUxV16XUk5upccAMDND7RY9PHpKSJS6I0zde/D3svq9/Wx8+c+9/L8z7gh7ANwkBBiwn71b2j0WHjSPLNHkQ61uwftoG+Wiy+X5CC9ldK3UmSJpCJvtFNSox5mxa96/iCCKfOrtWv2UwXjQrLVnA3cTQra1sfKub2myx3KoYs7UKLKe4vyTm/pKkU7VBsbTVrYrZC3bXCqsCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAPTdlPS8plDLpb0icX7S13s4zXCv5m+CCFJP5vryX4p+8FdYbRNPkoapXpUvFx3w1ecVfBP6o38sD9bp7ZQFdXZvZjWhRi0SGyfddHIt6tdshCQfUy9ybN1T5E4C3gfZCWvzsw5hwG2s4I12/w9V4l8oZk2CkC2so7TdHEOXHS2lGVcQIwSPoMlF+jly+wIdIz4Y6Zf0dzP6z9I/ckws9i3i5OlJSpKDGFRoqpQRxN8VfUdYchF0hvrnbS79Uxz+j7OhFr5+S6sO9dHW6iH0BLvjfIER0iLe8VYwIhBstovrJD1F5lCedk1XTObKTRJe86A89G7LLi/Ixd/oGyHLZdg==</X509Certificate>
            </X509Data>
        </KeyInfo>
    </ds:Signature>
    <RoleDescriptor xsi:type="fed:ApplicationServiceType" protocolSupportEnumeration="http://docs.oasis-open.org/ws-sx/ws-trust/200512 http://schemas.xmlsoap.org/ws/2005/02/trust http://docs.oasis-open.org/wsfed/federation/200706" ServiceDisplayName="dataworks.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:fed="http://docs.oasis-open.org/wsfed/federation/200706">
        <KeyDescriptor use="encryption">
            <KeyInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
                <X509Data>
                    <X509Certificate>MIIC3DCCAcSgAwIBAgIQH9STQYjVQZVEW52H5IN/XjANBgkqhkiG9w0BAQsFADAqMSgwJgYDVQQDEx9BREZTIEVuY3J5cHRpb24gLSBkYXRhd29ya3MuY29tMB4XDTIwMDMxMDE1NTMwOFoXDTIxMDMxMDE1NTMwOFowKjEoMCYGA1UEAxMfQURGUyBFbmNyeXB0aW9uIC0gZGF0YXdvcmtzLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMqZzQ9t7WME9D5zmMMvBfEVhlfaRKXNGuQg3vKmsYPtjUTrPB0nXCHVyXYKLhO6AJ3LNryD/9TLgqWqv1yDK+17GdX4aAND4hfSK0B98QzAoKZx+uM4tYZdlwSIshnfTtjO5LZWzYzeXzrovQ2fFKONeh0q3C0OPduO91sOR7sYEE2Y1BYJKy1R2+LfFDmr0fTRFwcdmy+zIH/F/6G2Dn29+tVeAj1wmbsu8ytROrRUVyjyJBNVykzuT2UbM9y+l2AQzD/p0XpItRucSzWH1hnVsR03uczHeqMqRFb6NtsL/vsYvm+n4qSH2IVwuY9xAJXhuCj2nBwne9E2QmboW3cCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAtf56fKh5vdcZQ/5xA9vUjn1xktAtvA/l14da8hngWNTb/6xrEFHSuu2IRJQG+e3q/BHRs6Hyh1EE9Mzogf4RVw1rYbGcYZhyutnzr5wp8jCfkT2AxeZrp5WODdiYh+fehND4N+d5fyJ4/H0DDIYi3G114uc7GyrqKf0ARpenxL/tb6dCzJeKcqH9hXXwpy8tQF76Pqd/BLlYrZk+uvE2dBYUgMYGP/S6UKHi65mnPhI4R+P4BRb2JPOJ20QcL3lmEx2vonsXfiAJkq49/FqVbWaLgz090LN0Dq2yw/+ELkjxrIJLlXmaxJdY32R3L3NE4nGPU6jq3wfcy2/QYBnNeg==</X509Certificate>
                </X509Data>
            </KeyInfo>
        </KeyDescriptor>
        <fed:ClaimTypesRequested>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>E-Mail Address</auth:DisplayName>
                <auth:Description>The e-mail address of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Given Name</auth:DisplayName>
                <auth:Description>The given name of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Name</auth:DisplayName>
                <auth:Description>The unique name of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>UPN</auth:DisplayName>
                <auth:Description>The user principal name (UPN) of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/claims/CommonName" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Common Name</auth:DisplayName>
                <auth:Description>The common name of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/claims/EmailAddress" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>AD FS 1.x E-Mail Address</auth:DisplayName>
                <auth:Description>The e-mail address of the user when interoperating with AD FS 1.1 or AD FS 1.0</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/claims/Group" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Group</auth:DisplayName>
                <auth:Description>A group that the user is a member of</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/claims/UPN" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>AD FS 1.x UPN</auth:DisplayName>
                <auth:Description>The UPN of the user when interoperating with AD FS 1.1 or AD FS 1.0</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2008/06/identity/claims/role" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Role</auth:DisplayName>
                <auth:Description>A role that the user has</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Surname</auth:DisplayName>
                <auth:Description>The surname of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/privatepersonalidentifier" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>PPID</auth:DisplayName>
                <auth:Description>The private identifier of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Name ID</auth:DisplayName>
                <auth:Description>The SAML name identifier of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2008/06/identity/claims/authenticationinstant" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Authentication time stamp</auth:DisplayName>
                <auth:Description>Used to display the time and date that the user was authenticated</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2008/06/identity/claims/authenticationmethod" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Authentication method</auth:DisplayName>
                <auth:Description>The method used to authenticate the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/denyonlysid" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Deny only group SID</auth:DisplayName>
                <auth:Description>The deny-only group SID of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2008/06/identity/claims/denyonlyprimarysid" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Deny only primary SID</auth:DisplayName>
                <auth:Description>The deny-only primary SID of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2008/06/identity/claims/denyonlyprimarygroupsid" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Deny only primary group SID</auth:DisplayName>
                <auth:Description>The deny-only primary group SID of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2008/06/identity/claims/groupsid" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Group SID</auth:DisplayName>
                <auth:Description>The group SID of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2008/06/identity/claims/primarygroupsid" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Primary group SID</auth:DisplayName>
                <auth:Description>The primary group SID of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2008/06/identity/claims/primarysid" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Primary SID</auth:DisplayName>
                <auth:Description>The primary SID of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Windows account name</auth:DisplayName>
                <auth:Description>The domain account name of the user in the form of domain\user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/devicecontext/claims/isregistereduser" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Is Registered User</auth:DisplayName>
                <auth:Description>User is registered to use this device</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/devicecontext/claims/identifier" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Device Identifier</auth:DisplayName>
                <auth:Description>Identifier of the device</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/devicecontext/claims/registrationid" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Device Registration Identifier</auth:DisplayName>
                <auth:Description>Identifier for Device Registration</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/devicecontext/claims/displayname" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Device Registration DisplayName</auth:DisplayName>
                <auth:Description>Display name of Device Registration</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/devicecontext/claims/ostype" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Device OS type</auth:DisplayName>
                <auth:Description>OS type of the device</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/devicecontext/claims/osversion" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Device OS Version</auth:DisplayName>
                <auth:Description>OS version of the device</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/devicecontext/claims/ismanaged" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Is Managed Device</auth:DisplayName>
                <auth:Description>Device is managed by a management service</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/requestcontext/claims/x-ms-forwarded-client-ip" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Forwarded Client IP</auth:DisplayName>
                <auth:Description>IP address of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/requestcontext/claims/x-ms-client-application" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Client Application</auth:DisplayName>
                <auth:Description>Type of the Client Application</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/requestcontext/claims/x-ms-client-user-agent" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Client User Agent</auth:DisplayName>
                <auth:Description>Device type the client is using to access the application</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/requestcontext/claims/x-ms-client-ip" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Client IP</auth:DisplayName>
                <auth:Description>IP address of the client</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/requestcontext/claims/x-ms-endpoint-absolute-path" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Endpoint Path</auth:DisplayName>
                <auth:Description>Absolute Endpoint path which can be used to determine active versus passive clients</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/requestcontext/claims/x-ms-proxy" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Proxy</auth:DisplayName>
                <auth:Description>DNS name of the federation server proxy that passed the request</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/requestcontext/claims/relyingpartytrustid" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Application Identifier</auth:DisplayName>
                <auth:Description>Identifier for the Relying Party</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/extension/applicationpolicy" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Application policies</auth:DisplayName>
                <auth:Description>Application policies of the certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/extension/authoritykeyidentifier" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Authority Key Identifier</auth:DisplayName>
                <auth:Description>The Authority Key Identifier extension of the certificate that signed an issued certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/extension/basicconstraints" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Basic Constraint</auth:DisplayName>
                <auth:Description>One of the basic constraints of the certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/extension/eku" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Enhanced Key Usage</auth:DisplayName>
                <auth:Description>Describes one of the enhanced key usages of the certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/field/issuer" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Issuer</auth:DisplayName>
                <auth:Description>The name of the certificate authority that issued the X.509 certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/field/issuername" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Issuer Name</auth:DisplayName>
                <auth:Description>The distinguished name of the certificate issuer</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/extension/keyusage" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Key Usage</auth:DisplayName>
                <auth:Description>One of the key usages of the certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/field/notafter" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Not After</auth:DisplayName>
                <auth:Description>Date in local time after which a certificate is no longer valid</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/field/notbefore" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Not Before</auth:DisplayName>
                <auth:Description>The date in local time on which a certificate becomes valid</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/extension/certificatepolicy" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Certificate Policies</auth:DisplayName>
                <auth:Description>The policies under which the certificate has been issued</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/rsa" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Public Key</auth:DisplayName>
                <auth:Description>Public Key of the certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/field/rawdata" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Certificate Raw Data</auth:DisplayName>
                <auth:Description>The raw data of the certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/extension/san" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Subject Alternative Name</auth:DisplayName>
                <auth:Description>One of the alternative names of the certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2008/06/identity/claims/serialnumber" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Serial Number</auth:DisplayName>
                <auth:Description>The serial number of a certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/field/signaturealgorithm" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Signature Algorithm</auth:DisplayName>
                <auth:Description>The algorithm used to create the signature of a certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/field/subject" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Subject</auth:DisplayName>
                <auth:Description>The subject from the certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/extension/subjectkeyidentifier" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Subject Key Identifier</auth:DisplayName>
                <auth:Description>Describes the subject key identifier of the certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/field/subjectname" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Subject Name</auth:DisplayName>
                <auth:Description>The subject distinguished name from a certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/extension/certificatetemplateinformation" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>V2 Template Name</auth:DisplayName>
                <auth:Description>The name of the version 2 certificate template used when issuing or renewing a certificate. The extension is Microsoft specific.</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/extension/certificatetemplatename" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>V1 Template Name</auth:DisplayName>
                <auth:Description>The name of the version 1 certificate template used when issuing or renewing a certificate. The extension is Microsoft specific.</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/thumbprint" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Thumbprint</auth:DisplayName>
                <auth:Description>Thumbprint of the certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/field/x509version" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>X.509 Version</auth:DisplayName>
                <auth:Description>The X.509 format version of a certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2012/01/insidecorporatenetwork" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Inside Corporate Network</auth:DisplayName>
                <auth:Description>Used to indicate if a request originated inside corporate network</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2012/01/passwordexpirationtime" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Password Expiration Time</auth:DisplayName>
                <auth:Description>Used to display the time when the password expires</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2012/01/passwordexpirationdays" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Password Expiration Days</auth:DisplayName>
                <auth:Description>Used to display the number of days to password expiry</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2012/01/passwordchangeurl" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Update Password URL</auth:DisplayName>
                <auth:Description>Used to display the web address of update password service</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/claims/authnmethodsreferences" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Authentication Methods References</auth:DisplayName>
                <auth:Description>Used to indicate all authentication methods used to authenticate the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/requestcontext/claims/client-request-id" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Client Request ID</auth:DisplayName>
                <auth:Description>Identifier for a user session</auth:Description>
            </auth:ClaimType>
        </fed:ClaimTypesRequested>
        <fed:TargetScopes>
            <EndpointReference xmlns="http://www.w3.org/2005/08/addressing">
                <Address>https://dataworks.com/adfs/services/trust/2005/issuedtokenmixedasymmetricbasic256</Address>
            </EndpointReference>
            <EndpointReference xmlns="http://www.w3.org/2005/08/addressing">
                <Address>https://dataworks.com/adfs/services/trust/2005/issuedtokenmixedsymmetricbasic256</Address>
            </EndpointReference>
            <EndpointReference xmlns="http://www.w3.org/2005/08/addressing">
                <Address>https://dataworks.com/adfs/services/trust/13/issuedtokenmixedasymmetricbasic256</Address>
            </EndpointReference>
            <EndpointReference xmlns="http://www.w3.org/2005/08/addressing">
                <Address>https://dataworks.com/adfs/services/trust/13/issuedtokenmixedsymmetricbasic256</Address>
            </EndpointReference>
            <EndpointReference xmlns="http://www.w3.org/2005/08/addressing">
                <Address>https://dataworks.com/adfs/ls/</Address>
            </EndpointReference>
            <EndpointReference xmlns="http://www.w3.org/2005/08/addressing">
                <Address>http://dataworks.com/adfs/services/trust</Address>
            </EndpointReference>
        </fed:TargetScopes>
        <fed:ApplicationServiceEndpoint>
            <EndpointReference xmlns="http://www.w3.org/2005/08/addressing">
                <Address>https://dataworks.com/adfs/services/trust/2005/issuedtokenmixedasymmetricbasic256</Address>
            </EndpointReference>
        </fed:ApplicationServiceEndpoint>
        <fed:PassiveRequestorEndpoint>
            <EndpointReference xmlns="http://www.w3.org/2005/08/addressing">
                <Address>https://dataworks.com/adfs/ls/</Address>
            </EndpointReference>
        </fed:PassiveRequestorEndpoint>
    </RoleDescriptor>
    <RoleDescriptor xsi:type="fed:SecurityTokenServiceType" protocolSupportEnumeration="http://docs.oasis-open.org/ws-sx/ws-trust/200512 http://schemas.xmlsoap.org/ws/2005/02/trust http://docs.oasis-open.org/wsfed/federation/200706" ServiceDisplayName="dataworks.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:fed="http://docs.oasis-open.org/wsfed/federation/200706">
        <KeyDescriptor use="signing">
            <KeyInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
                <X509Data>
                    <X509Certificate>MIIC1jCCAb6gAwIBAgIQO4dczEh1Gp1FW6B50JVlAzANBgkqhkiG9w0BAQsFADAnMSUwIwYDVQQDExxBREZTIFNpZ25pbmcgLSBkYXRhd29ya3MuY29tMB4XDTIwMDMxMDE1NTMwOFoXDTIxMDMxMDE1NTMwOFowJzElMCMGA1UEAxMcQURGUyBTaWduaW5nIC0gZGF0YXdvcmtzLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKw6nn1oJ7GbgmtSn8qSILRJlmyGG+MJb+4NQ3NfsTadspj3u1GTi4yls/MydhaWe/+ow3VgudJXRB0uoWy3+mez/4u1bM9SpRAHKbjM/qbbrUAKK0wIpe0+37kQRrUUUbOzo48sCsoHcUxV16XUk5upccAMDND7RY9PHpKSJS6I0zde/D3svq9/Wx8+c+9/L8z7gh7ANwkBBiwn71b2j0WHjSPLNHkQ61uwftoG+Wiy+X5CC9ldK3UmSJpCJvtFNSox5mxa96/iCCKfOrtWv2UwXjQrLVnA3cTQra1sfKub2myx3KoYs7UKLKe4vyTm/pKkU7VBsbTVrYrZC3bXCqsCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAPTdlPS8plDLpb0icX7S13s4zXCv5m+CCFJP5vryX4p+8FdYbRNPkoapXpUvFx3w1ecVfBP6o38sD9bp7ZQFdXZvZjWhRi0SGyfddHIt6tdshCQfUy9ybN1T5E4C3gfZCWvzsw5hwG2s4I12/w9V4l8oZk2CkC2so7TdHEOXHS2lGVcQIwSPoMlF+jly+wIdIz4Y6Zf0dzP6z9I/ckws9i3i5OlJSpKDGFRoqpQRxN8VfUdYchF0hvrnbS79Uxz+j7OhFr5+S6sO9dHW6iH0BLvjfIER0iLe8VYwIhBstovrJD1F5lCedk1XTObKTRJe86A89G7LLi/Ixd/oGyHLZdg==</X509Certificate>
                </X509Data>
            </KeyInfo>
        </KeyDescriptor>
        <fed:TokenTypesOffered>
            <fed:TokenType Uri="urn:oasis:names:tc:SAML:2.0:assertion" />
            <fed:TokenType Uri="urn:oasis:names:tc:SAML:1.0:assertion" />
        </fed:TokenTypesOffered>
        <fed:ClaimTypesOffered>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>E-Mail Address</auth:DisplayName>
                <auth:Description>The e-mail address of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Given Name</auth:DisplayName>
                <auth:Description>The given name of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Name</auth:DisplayName>
                <auth:Description>The unique name of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>UPN</auth:DisplayName>
                <auth:Description>The user principal name (UPN) of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/claims/CommonName" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Common Name</auth:DisplayName>
                <auth:Description>The common name of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/claims/EmailAddress" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>AD FS 1.x E-Mail Address</auth:DisplayName>
                <auth:Description>The e-mail address of the user when interoperating with AD FS 1.1 or AD FS 1.0</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/claims/Group" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Group</auth:DisplayName>
                <auth:Description>A group that the user is a member of</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/claims/UPN" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>AD FS 1.x UPN</auth:DisplayName>
                <auth:Description>The UPN of the user when interoperating with AD FS 1.1 or AD FS 1.0</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2008/06/identity/claims/role" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Role</auth:DisplayName>
                <auth:Description>A role that the user has</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Surname</auth:DisplayName>
                <auth:Description>The surname of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/privatepersonalidentifier" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>PPID</auth:DisplayName>
                <auth:Description>The private identifier of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Name ID</auth:DisplayName>
                <auth:Description>The SAML name identifier of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2008/06/identity/claims/authenticationinstant" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Authentication time stamp</auth:DisplayName>
                <auth:Description>Used to display the time and date that the user was authenticated</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2008/06/identity/claims/authenticationmethod" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Authentication method</auth:DisplayName>
                <auth:Description>The method used to authenticate the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/denyonlysid" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Deny only group SID</auth:DisplayName>
                <auth:Description>The deny-only group SID of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2008/06/identity/claims/denyonlyprimarysid" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Deny only primary SID</auth:DisplayName>
                <auth:Description>The deny-only primary SID of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2008/06/identity/claims/denyonlyprimarygroupsid" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Deny only primary group SID</auth:DisplayName>
                <auth:Description>The deny-only primary group SID of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2008/06/identity/claims/groupsid" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Group SID</auth:DisplayName>
                <auth:Description>The group SID of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2008/06/identity/claims/primarygroupsid" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Primary group SID</auth:DisplayName>
                <auth:Description>The primary group SID of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2008/06/identity/claims/primarysid" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Primary SID</auth:DisplayName>
                <auth:Description>The primary SID of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Windows account name</auth:DisplayName>
                <auth:Description>The domain account name of the user in the form of domain\user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/devicecontext/claims/isregistereduser" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Is Registered User</auth:DisplayName>
                <auth:Description>User is registered to use this device</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/devicecontext/claims/identifier" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Device Identifier</auth:DisplayName>
                <auth:Description>Identifier of the device</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/devicecontext/claims/registrationid" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Device Registration Identifier</auth:DisplayName>
                <auth:Description>Identifier for Device Registration</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/devicecontext/claims/displayname" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Device Registration DisplayName</auth:DisplayName>
                <auth:Description>Display name of Device Registration</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/devicecontext/claims/ostype" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Device OS type</auth:DisplayName>
                <auth:Description>OS type of the device</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/devicecontext/claims/osversion" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Device OS Version</auth:DisplayName>
                <auth:Description>OS version of the device</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/devicecontext/claims/ismanaged" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Is Managed Device</auth:DisplayName>
                <auth:Description>Device is managed by a management service</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/requestcontext/claims/x-ms-forwarded-client-ip" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Forwarded Client IP</auth:DisplayName>
                <auth:Description>IP address of the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/requestcontext/claims/x-ms-client-application" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Client Application</auth:DisplayName>
                <auth:Description>Type of the Client Application</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/requestcontext/claims/x-ms-client-user-agent" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Client User Agent</auth:DisplayName>
                <auth:Description>Device type the client is using to access the application</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/requestcontext/claims/x-ms-client-ip" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Client IP</auth:DisplayName>
                <auth:Description>IP address of the client</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/requestcontext/claims/x-ms-endpoint-absolute-path" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Endpoint Path</auth:DisplayName>
                <auth:Description>Absolute Endpoint path which can be used to determine active versus passive clients</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/requestcontext/claims/x-ms-proxy" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Proxy</auth:DisplayName>
                <auth:Description>DNS name of the federation server proxy that passed the request</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/requestcontext/claims/relyingpartytrustid" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Application Identifier</auth:DisplayName>
                <auth:Description>Identifier for the Relying Party</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/extension/applicationpolicy" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Application policies</auth:DisplayName>
                <auth:Description>Application policies of the certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/extension/authoritykeyidentifier" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Authority Key Identifier</auth:DisplayName>
                <auth:Description>The Authority Key Identifier extension of the certificate that signed an issued certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/extension/basicconstraints" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Basic Constraint</auth:DisplayName>
                <auth:Description>One of the basic constraints of the certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/extension/eku" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Enhanced Key Usage</auth:DisplayName>
                <auth:Description>Describes one of the enhanced key usages of the certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/field/issuer" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Issuer</auth:DisplayName>
                <auth:Description>The name of the certificate authority that issued the X.509 certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/field/issuername" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Issuer Name</auth:DisplayName>
                <auth:Description>The distinguished name of the certificate issuer</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/extension/keyusage" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Key Usage</auth:DisplayName>
                <auth:Description>One of the key usages of the certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/field/notafter" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Not After</auth:DisplayName>
                <auth:Description>Date in local time after which a certificate is no longer valid</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/field/notbefore" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Not Before</auth:DisplayName>
                <auth:Description>The date in local time on which a certificate becomes valid</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/extension/certificatepolicy" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Certificate Policies</auth:DisplayName>
                <auth:Description>The policies under which the certificate has been issued</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/rsa" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Public Key</auth:DisplayName>
                <auth:Description>Public Key of the certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/field/rawdata" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Certificate Raw Data</auth:DisplayName>
                <auth:Description>The raw data of the certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/extension/san" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Subject Alternative Name</auth:DisplayName>
                <auth:Description>One of the alternative names of the certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2008/06/identity/claims/serialnumber" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Serial Number</auth:DisplayName>
                <auth:Description>The serial number of a certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/field/signaturealgorithm" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Signature Algorithm</auth:DisplayName>
                <auth:Description>The algorithm used to create the signature of a certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/field/subject" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Subject</auth:DisplayName>
                <auth:Description>The subject from the certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/extension/subjectkeyidentifier" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Subject Key Identifier</auth:DisplayName>
                <auth:Description>Describes the subject key identifier of the certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/field/subjectname" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Subject Name</auth:DisplayName>
                <auth:Description>The subject distinguished name from a certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/extension/certificatetemplateinformation" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>V2 Template Name</auth:DisplayName>
                <auth:Description>The name of the version 2 certificate template used when issuing or renewing a certificate. The extension is Microsoft specific.</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/extension/certificatetemplatename" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>V1 Template Name</auth:DisplayName>
                <auth:Description>The name of the version 1 certificate template used when issuing or renewing a certificate. The extension is Microsoft specific.</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/thumbprint" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Thumbprint</auth:DisplayName>
                <auth:Description>Thumbprint of the certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/12/certificatecontext/field/x509version" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>X.509 Version</auth:DisplayName>
                <auth:Description>The X.509 format version of a certificate</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2012/01/insidecorporatenetwork" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Inside Corporate Network</auth:DisplayName>
                <auth:Description>Used to indicate if a request originated inside corporate network</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2012/01/passwordexpirationtime" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Password Expiration Time</auth:DisplayName>
                <auth:Description>Used to display the time when the password expires</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2012/01/passwordexpirationdays" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Password Expiration Days</auth:DisplayName>
                <auth:Description>Used to display the number of days to password expiry</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/ws/2012/01/passwordchangeurl" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Update Password URL</auth:DisplayName>
                <auth:Description>Used to display the web address of update password service</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/claims/authnmethodsreferences" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Authentication Methods References</auth:DisplayName>
                <auth:Description>Used to indicate all authentication methods used to authenticate the user</auth:Description>
            </auth:ClaimType>
            <auth:ClaimType Uri="http://schemas.microsoft.com/2012/01/requestcontext/claims/client-request-id" Optional="true" xmlns:auth="http://docs.oasis-open.org/wsfed/authorization/200706">
                <auth:DisplayName>Client Request ID</auth:DisplayName>
                <auth:Description>Identifier for a user session</auth:Description>
            </auth:ClaimType>
        </fed:ClaimTypesOffered>
        <fed:SecurityTokenServiceEndpoint>
            <EndpointReference xmlns="http://www.w3.org/2005/08/addressing">
                <Address>https://dataworks.com/adfs/services/trust/2005/certificatemixed</Address>
                <Metadata>
                    <Metadata xmlns="http://schemas.xmlsoap.org/ws/2004/09/mex" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsx="http://schemas.xmlsoap.org/ws/2004/09/mex">
                        <wsx:MetadataSection Dialect="http://schemas.xmlsoap.org/ws/2004/09/mex" xmlns="">
                            <wsx:MetadataReference>
                                <Address xmlns="http://www.w3.org/2005/08/addressing">https://dataworks.com/adfs/services/trust/mex</Address>
                            </wsx:MetadataReference>
                        </wsx:MetadataSection>
                    </Metadata>
                </Metadata>
            </EndpointReference>
        </fed:SecurityTokenServiceEndpoint>
        <fed:PassiveRequestorEndpoint>
            <EndpointReference xmlns="http://www.w3.org/2005/08/addressing">
                <Address>https://dataworks.com/adfs/ls/</Address>
            </EndpointReference>
        </fed:PassiveRequestorEndpoint>
    </RoleDescriptor>
    <SPSSODescriptor WantAssertionsSigned="true" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
        <KeyDescriptor use="encryption">
            <KeyInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
                <X509Data>
                    <X509Certificate>MIIC3DCCAcSgAwIBAgIQH9STQYjVQZVEW52H5IN/XjANBgkqhkiG9w0BAQsFADAqMSgwJgYDVQQDEx9BREZTIEVuY3J5cHRpb24gLSBkYXRhd29ya3MuY29tMB4XDTIwMDMxMDE1NTMwOFoXDTIxMDMxMDE1NTMwOFowKjEoMCYGA1UEAxMfQURGUyBFbmNyeXB0aW9uIC0gZGF0YXdvcmtzLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMqZzQ9t7WME9D5zmMMvBfEVhlfaRKXNGuQg3vKmsYPtjUTrPB0nXCHVyXYKLhO6AJ3LNryD/9TLgqWqv1yDK+17GdX4aAND4hfSK0B98QzAoKZx+uM4tYZdlwSIshnfTtjO5LZWzYzeXzrovQ2fFKONeh0q3C0OPduO91sOR7sYEE2Y1BYJKy1R2+LfFDmr0fTRFwcdmy+zIH/F/6G2Dn29+tVeAj1wmbsu8ytROrRUVyjyJBNVykzuT2UbM9y+l2AQzD/p0XpItRucSzWH1hnVsR03uczHeqMqRFb6NtsL/vsYvm+n4qSH2IVwuY9xAJXhuCj2nBwne9E2QmboW3cCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAtf56fKh5vdcZQ/5xA9vUjn1xktAtvA/l14da8hngWNTb/6xrEFHSuu2IRJQG+e3q/BHRs6Hyh1EE9Mzogf4RVw1rYbGcYZhyutnzr5wp8jCfkT2AxeZrp5WODdiYh+fehND4N+d5fyJ4/H0DDIYi3G114uc7GyrqKf0ARpenxL/tb6dCzJeKcqH9hXXwpy8tQF76Pqd/BLlYrZk+uvE2dBYUgMYGP/S6UKHi65mnPhI4R+P4BRb2JPOJ20QcL3lmEx2vonsXfiAJkq49/FqVbWaLgz090LN0Dq2yw/+ELkjxrIJLlXmaxJdY32R3L3NE4nGPU6jq3wfcy2/QYBnNeg==</X509Certificate>
                </X509Data>
            </KeyInfo>
        </KeyDescriptor>
        <KeyDescriptor use="signing">
            <KeyInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
                <X509Data>
                    <X509Certificate>MIIC1jCCAb6gAwIBAgIQO4dczEh1Gp1FW6B50JVlAzANBgkqhkiG9w0BAQsFADAnMSUwIwYDVQQDExxBREZTIFNpZ25pbmcgLSBkYXRhd29ya3MuY29tMB4XDTIwMDMxMDE1NTMwOFoXDTIxMDMxMDE1NTMwOFowJzElMCMGA1UEAxMcQURGUyBTaWduaW5nIC0gZGF0YXdvcmtzLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKw6nn1oJ7GbgmtSn8qSILRJlmyGG+MJb+4NQ3NfsTadspj3u1GTi4yls/MydhaWe/+ow3VgudJXRB0uoWy3+mez/4u1bM9SpRAHKbjM/qbbrUAKK0wIpe0+37kQRrUUUbOzo48sCsoHcUxV16XUk5upccAMDND7RY9PHpKSJS6I0zde/D3svq9/Wx8+c+9/L8z7gh7ANwkBBiwn71b2j0WHjSPLNHkQ61uwftoG+Wiy+X5CC9ldK3UmSJpCJvtFNSox5mxa96/iCCKfOrtWv2UwXjQrLVnA3cTQra1sfKub2myx3KoYs7UKLKe4vyTm/pKkU7VBsbTVrYrZC3bXCqsCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAPTdlPS8plDLpb0icX7S13s4zXCv5m+CCFJP5vryX4p+8FdYbRNPkoapXpUvFx3w1ecVfBP6o38sD9bp7ZQFdXZvZjWhRi0SGyfddHIt6tdshCQfUy9ybN1T5E4C3gfZCWvzsw5hwG2s4I12/w9V4l8oZk2CkC2so7TdHEOXHS2lGVcQIwSPoMlF+jly+wIdIz4Y6Zf0dzP6z9I/ckws9i3i5OlJSpKDGFRoqpQRxN8VfUdYchF0hvrnbS79Uxz+j7OhFr5+S6sO9dHW6iH0BLvjfIER0iLe8VYwIhBstovrJD1F5lCedk1XTObKTRJe86A89G7LLi/Ixd/oGyHLZdg==</X509Certificate>
                </X509Data>
            </KeyInfo>
        </KeyDescriptor>
        <SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="https://dataworks.com/adfs/ls/" />
        <SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://dataworks.com/adfs/ls/" />
        <NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress</NameIDFormat>
        <NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:persistent</NameIDFormat>
        <NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:transient</NameIDFormat>
        <AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://dataworks.com/adfs/ls/" index="0" isDefault="true" />
        <AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact" Location="https://dataworks.com/adfs/ls/" index="1" />
        <AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="https://dataworks.com/adfs/ls/" index="2" />
    </SPSSODescriptor>
    <IDPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
        <KeyDescriptor use="encryption">
            <KeyInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
                <X509Data>
                    <X509Certificate>MIIC3DCCAcSgAwIBAgIQH9STQYjVQZVEW52H5IN/XjANBgkqhkiG9w0BAQsFADAqMSgwJgYDVQQDEx9BREZTIEVuY3J5cHRpb24gLSBkYXRhd29ya3MuY29tMB4XDTIwMDMxMDE1NTMwOFoXDTIxMDMxMDE1NTMwOFowKjEoMCYGA1UEAxMfQURGUyBFbmNyeXB0aW9uIC0gZGF0YXdvcmtzLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMqZzQ9t7WME9D5zmMMvBfEVhlfaRKXNGuQg3vKmsYPtjUTrPB0nXCHVyXYKLhO6AJ3LNryD/9TLgqWqv1yDK+17GdX4aAND4hfSK0B98QzAoKZx+uM4tYZdlwSIshnfTtjO5LZWzYzeXzrovQ2fFKONeh0q3C0OPduO91sOR7sYEE2Y1BYJKy1R2+LfFDmr0fTRFwcdmy+zIH/F/6G2Dn29+tVeAj1wmbsu8ytROrRUVyjyJBNVykzuT2UbM9y+l2AQzD/p0XpItRucSzWH1hnVsR03uczHeqMqRFb6NtsL/vsYvm+n4qSH2IVwuY9xAJXhuCj2nBwne9E2QmboW3cCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAtf56fKh5vdcZQ/5xA9vUjn1xktAtvA/l14da8hngWNTb/6xrEFHSuu2IRJQG+e3q/BHRs6Hyh1EE9Mzogf4RVw1rYbGcYZhyutnzr5wp8jCfkT2AxeZrp5WODdiYh+fehND4N+d5fyJ4/H0DDIYi3G114uc7GyrqKf0ARpenxL/tb6dCzJeKcqH9hXXwpy8tQF76Pqd/BLlYrZk+uvE2dBYUgMYGP/S6UKHi65mnPhI4R+P4BRb2JPOJ20QcL3lmEx2vonsXfiAJkq49/FqVbWaLgz090LN0Dq2yw/+ELkjxrIJLlXmaxJdY32R3L3NE4nGPU6jq3wfcy2/QYBnNeg==</X509Certificate>
                </X509Data>
            </KeyInfo>
        </KeyDescriptor>
        <KeyDescriptor use="signing">
            <KeyInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
                <X509Data>
                    <X509Certificate>MIIC1jCCAb6gAwIBAgIQO4dczEh1Gp1FW6B50JVlAzANBgkqhkiG9w0BAQsFADAnMSUwIwYDVQQDExxBREZTIFNpZ25pbmcgLSBkYXRhd29ya3MuY29tMB4XDTIwMDMxMDE1NTMwOFoXDTIxMDMxMDE1NTMwOFowJzElMCMGA1UEAxMcQURGUyBTaWduaW5nIC0gZGF0YXdvcmtzLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKw6nn1oJ7GbgmtSn8qSILRJlmyGG+MJb+4NQ3NfsTadspj3u1GTi4yls/MydhaWe/+ow3VgudJXRB0uoWy3+mez/4u1bM9SpRAHKbjM/qbbrUAKK0wIpe0+37kQRrUUUbOzo48sCsoHcUxV16XUk5upccAMDND7RY9PHpKSJS6I0zde/D3svq9/Wx8+c+9/L8z7gh7ANwkBBiwn71b2j0WHjSPLNHkQ61uwftoG+Wiy+X5CC9ldK3UmSJpCJvtFNSox5mxa96/iCCKfOrtWv2UwXjQrLVnA3cTQra1sfKub2myx3KoYs7UKLKe4vyTm/pKkU7VBsbTVrYrZC3bXCqsCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAPTdlPS8plDLpb0icX7S13s4zXCv5m+CCFJP5vryX4p+8FdYbRNPkoapXpUvFx3w1ecVfBP6o38sD9bp7ZQFdXZvZjWhRi0SGyfddHIt6tdshCQfUy9ybN1T5E4C3gfZCWvzsw5hwG2s4I12/w9V4l8oZk2CkC2so7TdHEOXHS2lGVcQIwSPoMlF+jly+wIdIz4Y6Zf0dzP6z9I/ckws9i3i5OlJSpKDGFRoqpQRxN8VfUdYchF0hvrnbS79Uxz+j7OhFr5+S6sO9dHW6iH0BLvjfIER0iLe8VYwIhBstovrJD1F5lCedk1XTObKTRJe86A89G7LLi/Ixd/oGyHLZdg==</X509Certificate>
                </X509Data>
            </KeyInfo>
        </KeyDescriptor>
        <SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="https://dataworks.com/adfs/ls/" />
        <SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://dataworks.com/adfs/ls/" />
        <NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress</NameIDFormat>
        <NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:persistent</NameIDFormat>
        <NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:transient</NameIDFormat>
        <SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="https://dataworks.com/adfs/ls/" />
        <SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://dataworks.com/adfs/ls/" />
        <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="E-Mail Address" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Given Name" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Name" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="UPN" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.xmlsoap.org/claims/CommonName" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Common Name" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.xmlsoap.org/claims/EmailAddress" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="AD FS 1.x E-Mail Address" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.xmlsoap.org/claims/Group" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Group" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.xmlsoap.org/claims/UPN" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="AD FS 1.x UPN" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/ws/2008/06/identity/claims/role" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Role" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Surname" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/privatepersonalidentifier" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="PPID" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Name ID" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/ws/2008/06/identity/claims/authenticationinstant" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Authentication time stamp" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/ws/2008/06/identity/claims/authenticationmethod" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Authentication method" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/denyonlysid" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Deny only group SID" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/ws/2008/06/identity/claims/denyonlyprimarysid" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Deny only primary SID" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/ws/2008/06/identity/claims/denyonlyprimarygroupsid" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Deny only primary group SID" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/ws/2008/06/identity/claims/groupsid" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Group SID" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/ws/2008/06/identity/claims/primarygroupsid" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Primary group SID" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/ws/2008/06/identity/claims/primarysid" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Primary SID" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Windows account name" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/01/devicecontext/claims/isregistereduser" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Is Registered User" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/01/devicecontext/claims/identifier" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Device Identifier" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/01/devicecontext/claims/registrationid" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Device Registration Identifier" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/01/devicecontext/claims/displayname" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Device Registration DisplayName" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/01/devicecontext/claims/ostype" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Device OS type" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/01/devicecontext/claims/osversion" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Device OS Version" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/01/devicecontext/claims/ismanaged" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Is Managed Device" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/01/requestcontext/claims/x-ms-forwarded-client-ip" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Forwarded Client IP" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/01/requestcontext/claims/x-ms-client-application" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Client Application" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/01/requestcontext/claims/x-ms-client-user-agent" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Client User Agent" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/01/requestcontext/claims/x-ms-client-ip" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Client IP" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/01/requestcontext/claims/x-ms-endpoint-absolute-path" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Endpoint Path" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/01/requestcontext/claims/x-ms-proxy" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Proxy" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/01/requestcontext/claims/relyingpartytrustid" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Application Identifier" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/12/certificatecontext/extension/applicationpolicy" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Application policies" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/12/certificatecontext/extension/authoritykeyidentifier" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Authority Key Identifier" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/12/certificatecontext/extension/basicconstraints" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Basic Constraint" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/12/certificatecontext/extension/eku" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Enhanced Key Usage" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/12/certificatecontext/field/issuer" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Issuer" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/12/certificatecontext/field/issuername" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Issuer Name" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/12/certificatecontext/extension/keyusage" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Key Usage" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/12/certificatecontext/field/notafter" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Not After" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/12/certificatecontext/field/notbefore" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Not Before" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/12/certificatecontext/extension/certificatepolicy" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Certificate Policies" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/rsa" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Public Key" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/12/certificatecontext/field/rawdata" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Certificate Raw Data" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/12/certificatecontext/extension/san" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Subject Alternative Name" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/ws/2008/06/identity/claims/serialnumber" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Serial Number" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/12/certificatecontext/field/signaturealgorithm" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Signature Algorithm" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/12/certificatecontext/field/subject" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Subject" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/12/certificatecontext/extension/subjectkeyidentifier" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Subject Key Identifier" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/12/certificatecontext/field/subjectname" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Subject Name" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/12/certificatecontext/extension/certificatetemplateinformation" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="V2 Template Name" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/12/certificatecontext/extension/certificatetemplatename" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="V1 Template Name" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/thumbprint" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Thumbprint" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/12/certificatecontext/field/x509version" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="X.509 Version" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/ws/2012/01/insidecorporatenetwork" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Inside Corporate Network" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/ws/2012/01/passwordexpirationtime" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Password Expiration Time" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/ws/2012/01/passwordexpirationdays" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Password Expiration Days" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/ws/2012/01/passwordchangeurl" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Update Password URL" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/claims/authnmethodsreferences" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Authentication Methods References" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
        <Attribute Name="http://schemas.microsoft.com/2012/01/requestcontext/claims/client-request-id" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Client Request ID" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" />
    </IDPSSODescriptor>
</EntityDescriptor>