/*
 PureMVC AS3 Demo - Flex CafeTownsend
 Copyright (c) 2007-08 Michael Ramirez <michael.ramirez@puremvc.org>
 Parts Copyright (c) 2005-07 Adobe Systems, Inc. 
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package heatmap.controler.startup
{
    import heatmap.view.HeatmapVisualizationMediator;
    
    import org.puremvc.as3.multicore.interfaces.*;
    import org.puremvc.as3.multicore.patterns.command.*;
    import org.puremvc.as3.multicore.patterns.observer.*;

    
    /**
     * Prepare the View for use.
     * 
     * <P>
     * The <code>Notification</code> was sent by the <code>Application</code>,
     * and a reference to that view component was passed on the note body.
     * The <code>ApplicationMediator</code> will be created and registered using this
     * reference. The <code>ApplicationMediator</code> will then register 
     * all the <code>Mediator</code>s for the components it created.</P>
     * 
     */
    public class ViewPrepCommand extends SimpleCommand
    {
        override public function execute( note:INotification ) :void    
		{
            // Register the ApplicationMediator
            var application:Heatmap = note.getBody() as Heatmap;
             facade.registerMediator( new HeatmapVisualizationMediator( application.heatmapVisualization ) );            
           
        }

        
    }
}
