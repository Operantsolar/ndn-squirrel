/**
 * Copyright (C) 2016 Regents of the University of California.
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

function dump(message) { print(message); print("\n"); }

local TlvData = Blob([
0x06, 0xfd, 0x01, 0x50, // NDN Data
  0x07, 0x0a, 0x08, 0x03, 0x6e, 0x64, 0x6e, 0x08, 0x03, 0x61, 0x62, 0x63, // Name
  0x14, 0x0a, // MetaInfo
    0x19, 0x02, 0x13, 0x88, // FreshnessPeriod
    0x1a, 0x04, // FinalBlockId
      0x08, 0x02, 0x00, 0x09, // NameComponent
  0x15, 0x08, 0x53, 0x55, 0x43, 0x43, 0x45, 0x53, 0x53, 0x21, // Content
  0x16, 0x28, // SignatureInfo
    0x1b, 0x01, 0x01, // SignatureType
    0x1c, 0x23, // KeyLocator
      0x07, 0x21, // Name
        0x08, 0x08, 0x74, 0x65, 0x73, 0x74, 0x6e, 0x61, 0x6d, 0x65,
        0x08, 0x03, 0x4b, 0x45, 0x59,
        0x08, 0x07, 0x44, 0x53, 0x4b, 0x2d, 0x31, 0x32, 0x33,
        0x08, 0x07, 0x49, 0x44, 0x2d, 0x43, 0x45, 0x52, 0x54,
  0x17, 0xfd, 0x01, 0x00, // SignatureValue
    0x9b, 0x44, 0xaf, 0xcb, 0x26, 0xfd, 0x46, 0x9c, 0x9e, 0xb6, 0x2e, 0xed, 0x3c, 0x4d, 0x74, 0x4d,
    0xdb, 0x55, 0x7d, 0xb7, 0xc0, 0x47, 0x70, 0x9d, 0x10, 0x1d, 0x05, 0xb4, 0x94, 0x36, 0x3a, 0xcd,
    0x2a, 0xd6, 0xcf, 0x74, 0xbc, 0x6f, 0x71, 0x56, 0xe0, 0xba, 0x93, 0xa5, 0xd0, 0x14, 0x41, 0xdf,
    0x0c, 0x53, 0xad, 0xd6, 0x84, 0x3a, 0x2b, 0x29, 0x70, 0x34, 0x09, 0xb8, 0x0a, 0xca, 0x86, 0xec,
    0x25, 0xba, 0xb1, 0x19, 0x7e, 0xa7, 0x04, 0xc7, 0x1a, 0x33, 0xdd, 0x62, 0x71, 0x21, 0x89, 0x8e,
    0x83, 0x87, 0x1d, 0x9b, 0x94, 0xd7, 0x1a, 0x1e, 0x56, 0x1e, 0xaa, 0x41, 0xb4, 0x00, 0xc5, 0x03,
    0x67, 0xc3, 0xb0, 0x7f, 0x37, 0x30, 0xa6, 0x63, 0x8e, 0x28, 0xba, 0x76, 0x59, 0xc8, 0x52, 0x10,
    0xb5, 0x21, 0xd4, 0x39, 0x96, 0xf9, 0xdd, 0xbb, 0x33, 0xef, 0x33, 0x34, 0x47, 0x73, 0xf3, 0x35,
    0xc6, 0x62, 0xb5, 0x7f, 0x22, 0x58, 0x17, 0x2e, 0x0e, 0x84, 0xb7, 0xc2, 0xfe, 0x63, 0x13, 0xd3,
    0x95, 0x95, 0x51, 0x37, 0x9f, 0x61, 0x84, 0xc8, 0xfb, 0x31, 0xda, 0x2e, 0x58, 0xe5, 0xb9, 0x73,
    0xc5, 0xbb, 0xb4, 0x5c, 0xa2, 0xec, 0x68, 0xb3, 0xcc, 0xe3, 0x49, 0x7a, 0x49, 0x59, 0xa7, 0x5f,
    0xac, 0x37, 0x85, 0x7e, 0xb4, 0x4a, 0x16, 0x63, 0xd8, 0xac, 0xd2, 0xb1, 0xff, 0xca, 0xe5, 0x2f,
    0xf8, 0xe0, 0xb2, 0x0d, 0x69, 0x1f, 0xc3, 0x3f, 0xbf, 0x50, 0x4f, 0x5b, 0xfa, 0xa9, 0xf1, 0xeb,
    0x96, 0xce, 0xe4, 0xf3, 0xa7, 0x6b, 0xb4, 0xc7, 0x64, 0xd8, 0xf3, 0xe6, 0x04, 0x5b, 0x9d, 0xbf,
    0x23, 0xc0, 0xce, 0x72, 0xdf, 0xde, 0xbc, 0x0d, 0x48, 0x78, 0x4a, 0xe3, 0x39, 0x9b, 0x19, 0xb3,
    0x25, 0xba, 0xf8, 0xd0, 0x9c, 0xe5, 0x4d, 0xd8, 0x9b, 0x54, 0x3a, 0xcd, 0x9c, 0xdc, 0x22, 0xf3,
1
]);

function nameToRawUri(name) {
  if (name.size() == 0)
    return "/";

  local result = "";
  for (local i = 0; i < name.size(); ++i)
    result += "/" + name.get(i).getValue().toRawStr();

  return result;
}

function dumpData(data)
{
  dump("name: " + nameToRawUri(data.getName()));
  if (data.getContent().size() > 0) {
    dump("content (raw): " + data.getContent().toRawStr());
    dump("content (hex): " + data.getContent().toHex());
  }
  else
    dump("content: <empty>");

  if (!(data.getMetaInfo().getType() == ContentType.BLOB)) {
    if (data.getMetaInfo().getType() == ContentType.KEY)
      dump("metaInfo.type: KEY");
    else if (data.getMetaInfo().getType() == ContentType.LINK)
      dump("metaInfo.type: LINK");
    else if (data.getMetaInfo().getType() == ContentType.NACK)
      dump("metaInfo.type: NACK");
    else if (data.getMetaInfo().getType() == ContentType.OTHER_CODE)
      dump("metaInfo.type: other code " + data.getMetaInfo().getOtherTypeCode());
  }
  dump("metaInfo.freshnessPeriod (milliseconds): " +
    (data.getMetaInfo().getFreshnessPeriod() >= 0 ?
      "" + data.getMetaInfo().getFreshnessPeriod() : "<none>"));
  dump("metaInfo.finalBlockId: " +
    (data.getMetaInfo().getFinalBlockId().getValue().size() > 0 ?
     data.getMetaInfo().getFinalBlockId().getValue().toHex() : "<none>"));

  local keyLocator = null;
  local signature = data.getSignature();
  if (signature instanceof Sha256WithRsaSignature) {
    local signature = data.getSignature();
    dump("Sha256WithRsa signature.signature: " +
      (signature.getSignature().size() > 0 ?
       signature.getSignature().toHex() : "<none>"));
    keyLocator = signature.getKeyLocator();
  }
/*
  else if (signature instanceof HmacWithSha256Signature) {
    local signature = data.getSignature();
    dump("HmacWithSha256 signature.signature: " +
      (signature.getSignature().size() > 0 ?
       signature.getSignature().toHex() : "<none>"));
    keyLocator = signature.getKeyLocator();
  }
  else if (signature instanceof DigestSha256Signature) {
    local signature = data.getSignature();
    dump("DigestSha256 signature.signature: " +
      (signature.getSignature().size() > 0 ?
       signature.getSignature().toHex() : "<none>"));
  }
*/
  else if (signature instanceof GenericSignature) {
    local signature = data.getSignature();
    dump("Generic signature.signature: " +
      (signature.getSignature().size() > 0 ?
       signature.getSignature().toHex() : "<none>"));
    dump("  Type code: " + signature.getTypeCode() + " signatureInfo: " +
      (signature.getSignatureInfoEncoding().size() > 0 ?
       signature.getSignatureInfoEncoding().toHex() : "<none>"));
  }
  if (keyLocator != null) {
    if (keyLocator.getType() == null)
      dump("signature.keyLocator: <none>");
    else if (keyLocator.getType() == KeyLocatorType.KEY_LOCATOR_DIGEST)
      dump("signature.keyLocator: KeyLocatorDigest: " +
           keyLocator.getKeyData().toHex());
    else if (keyLocator.getType() == KeyLocatorType.KEYNAME)
      dump("signature.keyLocator: KeyName: " + 
           nameToRawUri(keyLocator.getKeyName()));
    else
      dump("signature.keyLocator: <unrecognized ndn_KeyLocatorType>");
  }
}

function main()
{
  local data = Data();
//  data.wireDecode(new Blob(TlvData, false));
  TlvWireFormat.decodeData(data, TlvData.buf());
  dump("Decoded Data:");
  dumpData(data);

  // Set the content again to clear the cached encoding so we encode again.
  data.setContent(data.getContent());
//  local encoding = data.wireEncode();
  local encoding = TlvWireFormat.encodeData(data).encoding;

  local reDecodedData = Data();
//  reDecodedData.wireDecode(encoding);
   TlvWireFormat.decodeData(reDecodedData, encoding.buf());
  dump("");
  dump("Re-decoded Data:");
  dumpData(reDecodedData);
}

// If running on the Imp, uncomment to redefine dump().
// function dump(message) { server.log(message); }
main();