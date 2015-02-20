package fovea.events;

#if js
class Event extends Dynamic
{
/**
    * The <code>ACTIVATE</code> constant defines the value of the
    * <code>type</code> property of an <code>activate</code> event object.
    *
    * <p><b>Note:</b> This event has neither a "capture phase" nor a "bubble
    * phase", which means that event listeners must be added directly to any
    * potential targets, whether the target is on the display list or not.</p>
    *
    * <p>AIR for TV devices never automatically dispatch this event. You can,
    * however, dispatch it manually.</p>
    *
    * <p>This event has the following properties:</p>
    */
public static var ACTIVATE = "activate";

/**
    * The <code>Event.ADDED</code> constant defines the value of the
    * <code>type</code> property of an <code>added</code> event object.
    *
    * <p>This event has the following properties:</p>
    */
public static var ADDED = "added";

/**
    * The <code>Event.ADDED_TO_STAGE</code> constant defines the value of the
    * <code>type</code> property of an <code>addedToStage</code> event object.
    *
    * <p>This event has the following properties:</p>
    */
public static var ADDED_TO_STAGE = "addedToStage";

/**
    * The <code>Event.CANCEL</code> constant defines the value of the
    * <code>type</code> property of a <code>cancel</code> event object.
    *
    * <p>This event has the following properties:</p>
    */
public static var CANCEL = "cancel";

/**
    * The <code>Event.CHANGE</code> constant defines the value of the
    * <code>type</code> property of a <code>change</code> event object.
    *
    * <p>This event has the following properties:</p>
    */
public static var CHANGE = "change";

/**
    * The <code>Event.CLOSE</code> constant defines the value of the
    * <code>type</code> property of a <code>close</code> event object.
    *
    * <p>This event has the following properties:</p>
    */
public static var CLOSE = "close";

/**
    * The <code>Event.COMPLETE</code> constant defines the value of the
    * <code>type</code> property of a <code>complete</code> event object.
    *
    * <p>This event has the following properties:</p>
    */
public static var COMPLETE = "complete";

/**
    * The <code>Event.CONNECT</code> constant defines the value of the
    * <code>type</code> property of a <code>connect</code> event object.
    *
    * <p>This event has the following properties:</p>
    */
public static var CONNECT = "connect";
public static var CONTEXT3D_CREATE = "context3DCreate";

/**
    * The <code>Event.DEACTIVATE</code> constant defines the value of the
    * <code>type</code> property of a <code>deactivate</code> event object.
    *
    * <p><b>Note:</b> This event has neither a "capture phase" nor a "bubble
    * phase", which means that event listeners must be added directly to any
    * potential targets, whether the target is on the display list or not.</p>
    *
    * <p>AIR for TV devices never automatically dispatch this event. You can,
    * however, dispatch it manually.</p>
    *
    * <p>This event has the following properties:</p>
    */
public static var DEACTIVATE = "deactivate";

/**
    * The <code>Event.ENTER_FRAME</code> constant defines the value of the
    * <code>type</code> property of an <code>enterFrame</code> event object.
    *
    * <p><b>Note:</b> This event has neither a "capture phase" nor a "bubble
    * phase", which means that event listeners must be added directly to any
    * potential targets, whether the target is on the display list or not.</p>
    *
    * <p>This event has the following properties:</p>
    */
public static var ENTER_FRAME = "enterFrame";

/**
    * The <code>Event.ID3</code> constant defines the value of the
    * <code>type</code> property of an <code>id3</code> event object.
    *
    * <p>This event has the following properties:</p>
    */
public static var ID3 = "id3";

/**
    * The <code>Event.INIT</code> constant defines the value of the
    * <code>type</code> property of an <code>init</code> event object.
    *
    * <p>This event has the following properties:</p>
    */
public static var INIT = "init";

/**
    * The <code>Event.MOUSE_LEAVE</code> constant defines the value of the
    * <code>type</code> property of a <code>mouseLeave</code> event object.
    *
    * <p>This event has the following properties:</p>
    */
public static var MOUSE_LEAVE = "mouseLeave";

/**
    * The <code>Event.OPEN</code> constant defines the value of the
    * <code>type</code> property of an <code>open</code> event object.
    *
    * <p>This event has the following properties:</p>
    */
public static var OPEN = "open";

/**
    * The <code>Event.REMOVED</code> constant defines the value of the
    * <code>type</code> property of a <code>removed</code> event object.
    *
    * <p>This event has the following properties:</p>
    */
public static var REMOVED = "removed";

/**
    * The <code>Event.REMOVED_FROM_STAGE</code> constant defines the value of
    * the <code>type</code> property of a <code>removedFromStage</code> event
    * object.
    *
    * <p>This event has the following properties:</p>
    */
public static var REMOVED_FROM_STAGE = "removedFromStage";

/**
    * The <code>Event.RENDER</code> constant defines the value of the
    * <code>type</code> property of a <code>render</code> event object.
    *
    * <p><b>Note:</b> This event has neither a "capture phase" nor a "bubble
    * phase", which means that event listeners must be added directly to any
    * potential targets, whether the target is on the display list or not.</p>
    *
    * <p>This event has the following properties:</p>
    */
public static var RENDER = "render";

/**
    * The <code>Event.RESIZE</code> constant defines the value of the
    * <code>type</code> property of a <code>resize</code> event object.
    *
    * <p>This event has the following properties:</p>
    */
public static var RESIZE = "resize";

/**
    * The <code>Event.SCROLL</code> constant defines the value of the
    * <code>type</code> property of a <code>scroll</code> event object.
    *
    * <p>This event has the following properties:</p>
    */
public static var SCROLL = "scroll";

/**
    * The <code>Event.SELECT</code> constant defines the value of the
    * <code>type</code> property of a <code>select</code> event object.
    *
    * <p>This event has the following properties:</p>
    */
public static var SELECT = "select";

/**
    * The <code>Event.SOUND_COMPLETE</code> constant defines the value of the
    * <code>type</code> property of a <code>soundComplete</code> event object.
    *
    * <p>This event has the following properties:</p>
    */
public static var SOUND_COMPLETE = "soundComplete";

/**
    * The <code>Event.TAB_CHILDREN_CHANGE</code> constant defines the value of
    * the <code>type</code> property of a <code>tabChildrenChange</code> event
    * object.
    *
    * <p>This event has the following properties:</p>
    */
public static var TAB_CHILDREN_CHANGE = "tabChildrenChange";

/**
    * The <code>Event.TAB_ENABLED_CHANGE</code> constant defines the value of
    * the <code>type</code> property of a <code>tabEnabledChange</code> event
    * object.
    *
    * <p>This event has the following properties:</p>
    */
public static var TAB_ENABLED_CHANGE = "tabEnabledChange";

/**
    * The <code>Event.TAB_INDEX_CHANGE</code> constant defines the value of the
    * <code>type</code> property of a <code>tabIndexChange</code> event object.
    *
    * <p>This event has the following properties:</p>
    */
public static var TAB_INDEX_CHANGE = "tabIndexChange";

/**
    * The <code>Event.UNLOAD</code> constant defines the value of the
    * <code>type</code> property of an <code>unload</code> event object.
    *
    * <p>This event has the following properties:</p>
    */
public static var UNLOAD = "unload";
}
#else
import openfl.events.Event;
typedef Event = openfl.events.Event ;
#end

