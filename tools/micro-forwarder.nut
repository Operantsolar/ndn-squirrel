/**
 * Copyright (C) 2016-2017 Regents of the University of California.
 * @author: Jeff Thompson <jefft0@remap.ucla.edu>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * A copy of the GNU Lesser General Public License is in the file COPYING.
 */

/**
 * A MicroForwarder holds a PIT, FIB and faces to function as a simple NDN
 * forwarder. It has a single instance which you can access with
 * MicroForwarder.get().
 */
class MicroForwarder {
  PIT_ = null;   // array of PitEntry
  FIB_ = null;   // array of FibEntry
  faces_ = null; // array of ForwarderFace
  canForward_ = null; // function

  static localhostNamePrefix = Name("/localhost");
  static broadcastNamePrefix = Name("/ndn/broadcast");

  /**
   * Create a new MicroForwarder. You must call addFace(). If running on the Imp
   * device, call addFace("internal://agent", agent).
   * Normally you do not create a MicroForwader, but use the static get().
   */
  constructor()
  {
    PIT_ = [];
    FIB_ = [];
    faces_ = [];
  }

  /**
   * Get a singleton instance of a MicroForwarder.
   * @return {MicroForwarder} The singleton instance.
   */
  static function get()
  {
    if (MicroForwarder_instance == null)
      ::MicroForwarder_instance = MicroForwarder();
    return MicroForwarder_instance;
  }

  /**
   * Add a new face to communicate with the given transport. This immediately
   * connects using the connectionInfo.
   * @param {string} uri The URI to use in the faces/query and faces/list
   * commands.
   * @param {Transport} transport An object of a subclass of Transport to use
   * for communication. If the transport object has a "setOnReceivedObject"
   * method, then use it to set the onReceivedObject callback.
   * @param {TransportConnectionInfo} connectionInfo This must be a
   * ConnectionInfo from the same subclass of Transport as transport.
   * @return {integer} The new face ID.
   */
  function addFace(uri, transport, connectionInfo)
  {
    local face = null;
    local thisForwarder = this;
    if ("setOnReceivedObject" in transport)
      transport.setOnReceivedObject
        (function(obj) { thisForwarder.onReceivedObject(face, obj); });
    face = ForwarderFace(uri, transport);

    transport.connect
      (connectionInfo,
       { onReceivedElement = function(element) {
           thisForwarder.onReceivedElement(face, element); } },
       function(){});
    faces_.append(face);

    return face.faceId;
  }

  /**
   * Set the canForward callback. When the MicroForwarder receives and interest
   * which matches the routing prefix on a face, it calls canForward as
   * described below to check if it is OK to forward to the face. This can be
   * used to implement a simple forwarding strategy.
   * @param {function} canForward If not null, the MicroForwarder calls
   * canForward(interest, incomingFaceUri, outgoingFaceUri, routePrefix) where
   * interest is the incoming Interest object, incomingFaceUri is the URI string
   * of the incoming face, outgoingFaceUri is the URI string of the outgoing
   * face, and routePrefix is the prefix Name of the matching outgoing route.
   * The canForward function should return true if it is OK to forward to the
   * outgoing face, else false.
   */
  function setCanForward(canForward) { canForward_ = canForward; }

  /**
   * Find or create the FIB entry with the given name and add the ForwarderFace
   * with the given faceId.
   * @param {Name} name The name of the FIB entry.
   * @param {integer} faceId The face ID of the face for the route.
   * @return {bool} True for success, or false if can't find the ForwarderFace
   * with faceId.
   */
  function registerRoute(name, faceId)
  {
    // Find the face with the faceId.
    local nexthopFace = null;
    for (local i = 0; i < faces_.len(); ++i) {
      if (faces_[i].faceId == faceId) {
        nexthopFace = faces_[i];
        break;
      }
    }

    if (nexthopFace == null)
      return false;

    // Check for a FIB entry for the name and add the face.
    for (local i = 0; i < FIB_.len(); ++i) {
      local fibEntry = FIB_[i];
      if (fibEntry.name.equals(name)) {
        // Make sure the face is not already added.
        if (fibEntry.faces.indexOf(nexthopFace) < 0)
          fibEntry.faces.push(nexthopFace);

        return true;
      }
    }

    // Make a new FIB entry.
    local fibEntry = FibEntry(name);
    fibEntry.faces.push(nexthopFace);
    FIB_.push(fibEntry);

    return true;
  }

  /**
   * This is called by the listener when an entire TLV element is received.
   * If it is an Interest, look in the FIB for forwarding. If it is a Data packet,
   * look in the PIT to match an Interest.
   * @param {ForwarderFace} face The ForwarderFace with the transport that
   * received the element.
   * @param {Buffer} element The received element.
   */
  function onReceivedElement(face, element)
  {
    local interest = null;
    local data = null;
    // Use Buffer.get to avoid using the metamethod.
    if (element.get(0) == Tlv.Interest || element.get(0) == Tlv.Data) {
      local decoder = TlvDecoder(element);
      if (decoder.peekType(Tlv.Interest, element.len())) {
        interest = Interest();
        interest.wireDecode(element, TlvWireFormat.get());
      }
      else if (decoder.peekType(Tlv.Data, element.len())) {
        data = Data();
        data.wireDecode(element, TlvWireFormat.get());
      }
    }

    local nowSeconds = NdnCommon.getNowSeconds();
    // Remove timed-out PIT entries
    // Iterate backwards so we can remove the entry and keep iterating.
    for (local i = PIT_.len() - 1; i >= 0; --i) {
      if (nowSeconds >= PIT_[i].timeoutEndSeconds)
        PIT_.remove(i);
    }

    // Now process as Interest or Data.
    if (interest != null) {
      if (localhostNamePrefix.match(interest.getName()))
        // Ignore localhost.
        return;

      // Check for a duplicate Interest.
      local timeoutEndSeconds;
      if (interest.getInterestLifetimeMilliseconds() != null)
        timeoutEndSeconds = nowSeconds + (interest.getInterestLifetimeMilliseconds() / 1000.0).tointeger();
      else
        // Use a default timeout.
        timeoutEndSeconds = nowSeconds + 4;
      for (local i = 0; i < PIT_.len(); ++i) {
        local entry = PIT_[i];
        // TODO: Check interest equality of appropriate selectors.
        if (entry.face == face &&
            entry.interest.getName().equals(interest.getName())) {
          // Duplicate PIT entry.
          // Update the interest timeout.
          if (timeoutEndSeconds > entry.timeoutEndSeconds)
            entry.timeoutEndSeconds = timeoutEndSeconds;

          return;
        }
      }

      // Add to the PIT.
      local pitEntry = PitEntry(interest, face, timeoutEndSeconds);
      PIT_.append(pitEntry);

      if (broadcastNamePrefix.match(interest.getName())) {
        // Special case: broadcast to all faces.
        for (local i = 0; i < faces_.len(); ++i) {
          local outFace = faces_[i];
          // Don't send the interest back to where it came from.
          if (outFace != face)
            outFace.sendBuffer(element);
        }
      }
      else {
        // Send the interest to the faces in matching FIB entries.
        for (local i = 0; i < FIB_.len(); ++i) {
          local fibEntry = FIB_[i];

          // TODO: Need to check all for longest prefix match?
          if (fibEntry.name.match(interest.getName())) {
            for (local j = 0; j < fibEntry.faces.len(); ++j) {
              local outFace = fibEntry.faces[j];
              // Don't send the interest back to where it came from.
              if (outFace != face) {
                if (canForward_ == null || canForward_
                    (interest, face.uri, outFace.uri, fibEntry.name))
                  outFace.sendBuffer(element);
              }
            }
          }
        }
      }
    }
    else if (data != null) {
      // Send the data packet to the face for each matching PIT entry.
      // Iterate backwards so we can remove the entry and keep iterating.
      for (local i = PIT_.len() - 1; i >= 0; --i) {
        local entry = PIT_[i];
        if (entry.face != face && entry.face != null &&
            entry.interest.matchesData(data)) {
          // Remove the entry before sending.
          PIT_.remove(i);

          entry.face.sendBuffer(element);
          entry.face = null;
        }
      }
    }
  }

  /**
   * This is called when an object is received on a local face.
   * @param {ForwarderFace} face The ForwarderFace with the transport that
   * received the object.
   * @param {table} obj A Squirrel table where obj.type is a string.
   */
  function onReceivedObject(face, obj)
  {
    if (!(typeof obj == "table" && "type" in obj))
      return;

    if (obj.type == "rib/register") {
      local faceId;
      if ("faceId" in obj && obj.faceId != null)
        faceId = obj.faceId;
      else
        // Use the requesting face.
        faceId = face.faceId;

      if (!registerRoute(Name(obj.nameUri), faceId))
        // TODO: Send error reply?
        return;

      obj.statusCode <- 200;
      face.sendObject(obj);
    }
  }
}

// We use a global variable because static member variables are immutable.
MicroForwarder_instance <- null;

/**
 * A PitEntry is used in the PIT to record the face on which an Interest came 
 * in. (This is not to be confused with the entry object used by the application
 * library's PendingInterestTable class.)
 * @param {Interest} interest
 * @param {ForwarderFace} face
 */
class PitEntry {
  interest = null;
  face = null;
  timeoutEndSeconds = null;

  constructor(interest, face, timeoutEndSeconds)
  {
    this.interest = interest;
    this.face = face;
    this.timeoutEndSeconds = timeoutEndSeconds;
  }
}

/**
 * A FibEntry is used in the FIB to match a registered name with related faces.
 * @param {Name} name The registered name for this FIB entry.
 */
class FibEntry {
  name = null;
  faces = null; // array of ForwarderFace

  constructor (name)
  {
    this.name = name;
    this.faces = [];
  }
}

/**
 * A ForwarderFace is used by the faces list to represent a connection using the
 * given Transport.
 */
class ForwarderFace {
  uri = null;
  transport = null;
  faceId = null;

  /**
   * Create a ForwarderFace and set the faceId to a unique value.
   * @param {string} uri The URI to use in the faces/query and faces/list
   * commands.
   * @param {Transport} transport Communicate using the Transport object. You
   * must call transport.connect with an elementListener object whose
   * onReceivedElement(element) calls
   * microForwarder.onReceivedElement(face, element), with this face. If available
   * the transport's onReceivedObject(obj) should call
   * microForwarder.onReceivedObject(face, obj), with this face.
   */
  constructor(uri, transport)
  {
    this.uri = uri;
    this.transport = transport;
    this.faceId = ++ForwarderFace_lastFaceId;
  }

  /**
   * Check if this face is still enabled.
   * @returns {bool} True if this face is still enabled.
   */
  function isEnabled() { return transport != null; }

  /**
   * Disable this face so that isEnabled() returns false.
   */
  function disable() { transport = null; };

  /**
   * Send the object to the transport, if this face is still enabled.
   * @param {object} obj The object to send.
   */
  function sendObject(obj)
  {
    if (transport != null && "sendObject" in transport)
      transport.sendObject(obj);
  }

  /**
   * Send the buffer to the transport, if this face is still enabled.
   * @param {Buffer} buffer The bytes to send.
   */
  function sendBuffer(buffer)
  {
    if (this.transport != null)
      this.transport.send(buffer);
  }
}

ForwarderFace_lastFaceId <- 0;
