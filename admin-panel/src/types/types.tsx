
export type OriginEventStatus = "opened"|"assigned"|"arrived"| "solved"| "closed" 

// types/Event.ts
export interface EventItem {
  id: number
  title: string
  location: string
  status: OriginEventStatus
  priority: 'low' | 'medium' | 'high' | 'critical'
  time: string
  user: string
}
export interface User {
  id: number;
  name: string;
  lastUpdate?: string;
  status?: string;
  event?: RowEvent | null;
  info?: string;
  dotType?: "single" | "multi" | "none" | "system";
  dotColor?: string;
  dotColors?: string[];
  unread?: number;
}

export interface  OriginGeoLocation { 
lat: number
lng: number 
} 


export interface OriginUser{

  	id: string
  	privateName: string
  	surName: string
  	email: string
  	phoneNumber: string
  	residenceAddress: string
  	workAddress: string
  	carType: string
  	carPlateNumber: string
  	role: "manager" | "dispatcher" | "user"
  	location?: OriginGeoLocation

}

export interface OriginEvent{
id: string 
title: string 
detail: string 
location: OriginGeoLocation 
status: OriginEventStatus 
customer: { 
privateName: string 
surName: string 
phone: string
carPlateNumber: string 
carType: string 
carColor: string 
carDescription: string 
notes: string 
} 
assignedUsers: string[] 
acceptedUsers: string[] 
solvedBy?: string 
closedBy?: string 
createdAt: string 
updatedAt: string 
}


export interface OriginMessages{
id: string 
eventId: string 
title?: string 
text?: string 
voiceUrl?: string 
location?: OriginGeoLocation 
user: { 
id: string 
privateName: string 
surName: string 
role: string 
} 
createdAt: string 
}


export interface RowEvent {
  label: string;
  badge?: string;
}
export type NavItem = {
  id: number;
  label: string;
  icon?: React.ReactNode;
  active?: boolean;
  route: string;
};

type MessageAlign = "left" | "right";
type MessageStatus = "sent" | "read";

interface BaseMessage {
  id: number;
  sender: string | null;
  align: MessageAlign;
  time: string;
  status: MessageStatus;
}



 export  interface TextMessage extends BaseMessage {
  type?: "text";
  text: string;
  hasReadMore?: boolean;
}

interface ImageMessage extends BaseMessage {
  type: "image";
  text?: never;
  hasReadMore?: never;
}
export type Message = TextMessage | ImageMessage;

export type ApiAlertStatus =
  | 'OPEN'
  | 'DISPATCHED'
  | 'ACCEPTED'
  | 'IN_PROGRESS'
  | 'RESOLVED'
  | 'CANCELLED';

export type ApiAlertPriority = 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';

export interface ApiAlert {
  id: number;
  title: string;
  description: string;
  latitude: number;
  longitude: number;
  status: ApiAlertStatus;
  priority: ApiAlertPriority;
  created_at: string;
  updated_at: string;
}

export interface ApiUserProfile {
  id: number;
  username: string;
  email: string;
  role: string;
  latitude: number | null;
  longitude: number | null;
}