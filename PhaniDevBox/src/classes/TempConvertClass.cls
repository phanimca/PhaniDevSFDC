public class TempConvertClass{

    public PageReference convert() {
        getConvert();
        return null;
    }


    public void getConvert() {
        
        soapSforceComSchemasClassTemparatur.TemparatureConversion  converter=new soapSforceComSchemasClassTemparatur.TemparatureConversion ();
        converter.clientCert_x='phani18.b@gmail.com.test.phanisand';
        converter.clientCertPasswd_x='Phani1239sKQi0jUBrVrWE1Gmgp2jSvr';
        if(c!=null){
          
          
          f=converter.C2F(100);
        
        }
    }


    public Double c{get;set;}
    
    public Double f{get;set;}
    
    
} // end of class