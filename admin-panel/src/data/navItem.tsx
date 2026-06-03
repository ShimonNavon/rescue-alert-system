import { type NavItem } from "../types/types";
import {
  Calendar,
  MapPin,
  MessageCircle,
  Mic,
  CircleAlert,
} from "lucide-react";

export  const navItems: NavItem[] = [
  {id: 1, label: "אירועים", icon: <Calendar size={16} />, active: true,route:"/events-table" },
  {id: 2, label: "מצב", icon: <CircleAlert size={16} />,route:"/situation" },
  {id: 3, label: "מפה", icon: <MapPin size={16} />,route:"/geography" },
  {id: 4, label: "צ׳אט", icon: <MessageCircle size={16} />,route:"/chat" },
  {id: 5, label: "PTT", icon: <Mic size={16} />,route:"/ptt" },
];
