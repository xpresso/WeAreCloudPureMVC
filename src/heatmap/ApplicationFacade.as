package heatmap
{
	import heatmap.controler.ExtractDataFromXmlFileCommand;
	import heatmap.controler.LoadXmlDataCommand;
	import heatmap.controler.startup.ApplicationStartupCommand;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	
	public class ApplicationFacade extends Facade implements IFacade
	{
		public static const NAME:String                               = 'heatmap';
		
		// Notification constants 
		public static const STARTUP:String 							  = 'startup';
		public static const LOAD_XML_DATA:String                      = 'loadXmlData';	
		public static const EXTRACT_DATA_FROM_XML_FILE:String         = 'extractDataFromXmlFile';
		public static const DATA_EXTRACTED:String                     = 'dataExtracted';
		public static const GEOCODE_ADRESSES:String                   = 'geocodeAdresses';
		
	   	
		
		public function ApplicationFacade( key:String )
		{
			super(key);	
		}
		
		public var application:Heatmap;
		 
        /**
         * Singleton ApplicationFacade Factory Method
         */
        public static function getInstance( key:String ) : ApplicationFacade 
        {
            if ( instanceMap[ key ] == null ) instanceMap[ key ] = new ApplicationFacade( key );
            return instanceMap[ key ] as ApplicationFacade;
        }
        
	    /**
         * Register Commands with the Controller 
         */
        override protected function initializeController( ) : void 
        {
            super.initializeController();            
          	registerCommand( STARTUP, heatmap.controler.startup.ApplicationStartupCommand  );
         	registerCommand( LOAD_XML_DATA, heatmap.controler.LoadXmlDataCommand  );
         	registerCommand( EXTRACT_DATA_FROM_XML_FILE, heatmap.controler.ExtractDataFromXmlFileCommand);          			
        }
        
        /**
         * Application startup
         * 
         * @param app a reference to the application component 
         */  
        public function startup( app:Heatmap ):void
        {
        	sendNotification( STARTUP, app );
        }

			
	}
}