import type { FC} from "react";
import  Navbar  from "../Navbar/Navbar";
import "./Layout.css";


type LayoutProps = {
  setWindowOpen: (open: boolean) => void;
};




const Layout: FC<LayoutProps> = ({ setWindowOpen }) => {
  return (
    <div className="layout">
        <Navbar setWindowOpen={setWindowOpen}  />
{/* 
      <main className="layout-content">
        {children}
      </main> */}
    </div>
  );
};

export default Layout;