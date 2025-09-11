import PaymentsTab from './PaymentsTab';

<Tab label="Payments" component={<PaymentsTab />} />
import React from 'react';
import Tabs from '@mui/material/Tabs';
import Tab from '@mui/material/Tab';

interface DashboardTabsProps {
  selectedTab: string;
  onChange: (event: React.SyntheticEvent, newValue: string) => void;
}

const DashboardTabs: React.FC<DashboardTabsProps> = ({ selectedTab, onChange }) => {
  return (
    <Tabs
      value={selectedTab}
      onChange={onChange}
      indicatorColor="primary"
      textColor="primary"
      variant="fullWidth"
      aria-label="dashboard tabs"
    >
      <Tab label="Overview" value="overview" />
      <Tab label="Transactions" value="transactions" />
      <Tab label="Payments" value="payments" />
      <Tab label="Settings" value="settings" />
    </Tabs>
  );
};

export default DashboardTabs;   