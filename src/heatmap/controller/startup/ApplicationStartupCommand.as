/*
 PureMVC AS3 Demo - Flex CafeTownsend
 Copyright (c) 2007-08 Michael Ramirez <michael.ramirez@puremvc.org>
 Parts Copyright (c) 2005-07 Adobe Systems, Inc. 
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package heatmap.controller.startup
{
    import org.puremvc.as3.multicore.patterns.command.*;
    import org.puremvc.as3.multicore.interfaces.*;

    /**
     * A MacroCommand executed when the application starts.
     *
       * @see org.puremvc.as3.demos.flex.cafetownsend.controller.ModelPrepCommand ModelPrepCommand 
       * @see org.puremvc.as3.demos.flex.cafetownsend.controller.ViewPrepCommand ViewPrepCommand 
     */
    public class ApplicationStartupCommand extends MacroCommand
    {
        
        /**
         * Initialize the MacroCommand by adding its SubCommands.
         * 
         * <P>
         * Since we built the UI using an MXML <code>Application</code> tag, those
         * components are created first. The top level <code>Application</code>
         * then initialized the <code>ApplicationFacade</code>, which in turn initialized 
         * the <code>Controller</code>, registering Commands. Then the 
         * <code>Application</code> sent the <code>APP_STARTUP
         * Notification</code>, leading to this <code>MacroCommand</code>&apos;s execution.</P>
         * 
         * <P>
         * It is important for us to create and register Proxys with the Model 
         * prior to creating and registering Mediators with the View, since 
         * availability of Model data is often essential to the proper 
         * initialization of the View.</P>
         * 
         * <P>
         * So, <code>ApplicationStartupCommand</code> first executes 
         * <code>ModelPrepCommand</code> followed by <code>ViewPrepCommand</code></P>
         * 
         */
        override protected function initializeMacroCommand() :void
        {
            addSubCommand( ModelPrepCommand );
            addSubCommand( ViewPrepCommand );
        }
        
    }
}
