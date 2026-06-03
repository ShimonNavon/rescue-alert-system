import { useState, useRef, type KeyboardEvent } from "react";
import {
  Search,
  MoreVertical,
  Smile,
  Paperclip,
  Send,
  Users,
  Check,
  CheckCheck,
  Image as ImageIcon,
} from "lucide-react";
import "./GroupChat.css";
import Avatar from "../../Avatar/Avatar";
import { INITIAL_MESSAGES } from "../../../data/initialMessages";
import { AVATAR_COLORS } from "../../../data/avatarColors";
import { type Message,type TextMessage } from "../../../types/types";

function nowTime(): string {
  return new Date().toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" });
}


function DoubleCheck({ color = "#53bdeb" }: { color?: string }) {
  return <CheckCheck size={15} color={color} className="gc-tick" />;
}

function SingleCheck() {
  return <Check size={13} color="#8696a0" className="gc-tick" />;
}


interface TextBubbleProps {
  msg: TextMessage;
  isExpanded: boolean;
  onExpand: () => void;
}

function TextBubble({ msg, isExpanded, onExpand }: TextBubbleProps) {
  const isLeft = msg.align === "left";
  const displayText =
    msg.hasReadMore && !isExpanded ? msg.text.slice(0, 140) + "... " : msg.text;

  return (
    <div className={`gc-bubble ${isLeft ? "gc-bubble--left" : "gc-bubble--right"}`}>
      {!isLeft && msg.sender && (
        <div
          className="gc-sender-name"
          style={{ color: AVATAR_COLORS[msg.sender] ?? "#5B8DEF" }}
        >
          {msg.sender}
        </div>
      )}

      <div className="gc-msg-text">
        {displayText}
        {msg.hasReadMore && !isExpanded && (
          <span className="gc-read-more" onClick={onExpand}>Read More</span>
        )}
      </div>

      <div className="gc-time-line">
        <span className="gc-time-text">{msg.time}</span>
        {isLeft ? <DoubleCheck color="#53bdeb" /> : <SingleCheck />}
      </div>
    </div>
  );
}



interface ImageBubbleProps {
  time: string;
}
 function ImageBubble({ time }: ImageBubbleProps) {
  return (
    <div className="gc-bubble gc-bubble--right gc-bubble--image">
      <div className="gc-image-placeholder">
        <ImageIcon size={40} color="#78909c" />
      </div>
      <div className="gc-time-line">
        <span className="gc-time-text">{time}</span>
        <DoubleCheck />
      </div>
    </div>
  );
}


export default function GroupChat() {
  const [messages, setMessages] = useState<Message[]>(INITIAL_MESSAGES);
  const [input, setInput]       = useState<string>("");
  const [expanded, setExpanded] = useState<Set<number>>(new Set());
  const bottomRef               = useRef<HTMLDivElement>(null);


  const sendMessage = (): void => {
    const text = input.trim();
    if (!text) return;
    const next: TextMessage = {
      id: Date.now(),
      sender: "me",
      text,
      align: "left",
      time: nowTime(),
      status: "sent",
    };
    setMessages((prev) => [...prev, next]);
    setInput("");
  };

  const handleKeyDown = (e: KeyboardEvent<HTMLInputElement>): void => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  const toggleExpand = (id: number): void =>
    setExpanded((prev) => new Set([...prev, id]));


  return (
    <div className="gc-root">
      {/* ── Header ── */}
      <header className="gc-header">
        <div className="gc-header__left">
          <div className="gc-header__group-avatar">
            <Users size={22}  />
          </div>
          <div>
            <div className="gc-header__name">Group 50</div>
            <div className="gc-header__sub">
              John Henry, Brian Wilson, Dan Gilad, George Ezra, Guy Levi...
            </div>
          </div>
        </div>

        <div className="gc-header__actions">
          <button className="gc-icon-btn" aria-label="Search">
            <Search size={20}  />
          </button>
          <button className="gc-icon-btn" aria-label="Menu">
            <MoreVertical size={20}  />
          </button>
        </div>
      </header>

      {/* ── Messages ── */}
      <main className="gc-body">
        <div className="gc-date-divider">
          <span className="gc-date-pill">Today</span>
        </div>

        {messages.map((msg) => {
          const isLeft = msg.align === "left";

          if (msg.type === "image") {
            return (
              <div key={msg.id} className="gc-msg-row gc-msg-row--right">
                <ImageBubble time={msg.time} />
              </div>
            );
          }

          return (
            <div
              key={msg.id}
              className={`gc-msg-row ${isLeft ? "gc-msg-row--left" : "gc-msg-row--right"}`}
            >
              {!isLeft && msg.sender && <Avatar row={{ name: msg.sender}} />}
              <TextBubble
                msg={msg as TextMessage}
                isExpanded={expanded.has(msg.id)}
                onExpand={() => toggleExpand(msg.id)}
              />
            </div>
          );
        })}

        <div ref={bottomRef} />
      </main>

      {/* ── Input bar ── */}
      <footer className="gc-input-bar">
        <button className="gc-icon-btn" aria-label="Emoji">
          <Smile size={22} />
        </button>

        <input
          className="gc-input"
          placeholder="Type a message"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={handleKeyDown}
          aria-label="Message input"
        />

        <button className="gc-icon-btn" aria-label="Attach file">
          <Paperclip size={22} />
        </button>

        <button
          className="gc-send-btn"
          onClick={sendMessage}
          disabled={!input.trim()}
          aria-label="Send message"
        >
          <Send size={18} color="white" className="gc-send-icon" />
        </button>
      </footer>

    </div>
  );
}
