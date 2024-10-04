// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const NFTGatedEventModule = buildModule("NFTGatedEventModule", (m) => {

   const nftAddress = "0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D";
   const maxParticipants = 200;
  

  const nftgatedevent= m.contract("NFTGatedEvent", [nftAddress, maxParticipants ]);

  return { nftgatedevent };
});

export default NFTGatedEventModule;
