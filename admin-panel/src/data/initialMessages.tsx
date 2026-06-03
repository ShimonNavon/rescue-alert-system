import { type Message } from "../types/types";

export const INITIAL_MESSAGES: Message[] = [
  { id: 1, sender: "", type: "image", align: "right", time: "16:23", status: "read" },
  {
    id: 2, sender: "me",
    text: "What exactly is a Lorry, where can we get one for the company?",
    align: "left", time: "16:23", status: "read",
  },
  {
    id: 3, sender: "Brian Wilson",
    text: "A lorry is a motor vehicle designed to transport cargo, carry specialized payloads, or perform other utilitarian work. Trucks vary greatly in size, power, and configuration, but the vast majority feature body-on-frame construction, with a cabin that is independent of the payload portion of the vehicle...",
    hasReadMore: true, align: "right", time: "16:23", status: "read",
  },
  { id: 4, sender: "me",       text: "Not sure if we need one",                                      align: "left",  time: "16:23", status: "read" },
  { id: 5, sender: "me",       text: "But better safe than sorry, let's get 5 of them",              align: "left",  time: "16:23", status: "read" },
  { id: 6, sender: "Guy Levi", text: "Cool!",                                                        align: "right", time: "16:25", status: "read" },
  { id: 7, sender: "me",       text: "Okay, see you soon!",                                          align: "left",  time: "16:23", status: "read" },
  { id: 8, sender: "me",       text: "Actually, 5 is too much. we should only get one and if its good we will buy the rest, we don't have infinite money... yet", align: "left", time: "16:23", status: "read" },
];