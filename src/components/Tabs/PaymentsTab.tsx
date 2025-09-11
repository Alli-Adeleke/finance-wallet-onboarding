import React, { useState } from 'react';
import MastercardIcon from '../icons/Mastercard';
import VisaIcon from '../icons/Visa';
import BitcoinIcon from '../icons/Bitcoin';
import MastercardProvision from '../Payments/MastercardProvision';
import VisaProvision from '../Payments/VisaProvision';
import BitcoinProvision from '../Payments/BitcoinProvision';

const PaymentsTab = () => {
  const [selected, setSelected] = useState<'mastercard' | 'visa' | 'bitcoin'>('mastercard');

  const renderProvision = () => {
    switch (selected) {
      case 'mastercard':
        return <MastercardProvision />;
      case 'visa':
        return <VisaProvision />;
      case 'bitcoin':
        return <BitcoinProvision />;
      default:
        return null;
    }
  };

  return (
    <div className="p-6 bg-white rounded-lg shadow-md">
      <h2 className="text-xl font-bold mb-4">💳 Payments & Provisioning</h2>
      <div className="flex space-x-4 mb-6">
        <button
          className={`tab-button ${selected === 'mastercard' ? 'active' : ''}`}
          onClick={() => setSelected('mastercard')}
        >
          <MastercardIcon /> Mastercard
        </button>
        <button
          className={`tab-button ${selected === 'visa' ? 'active' : ''}`}
          onClick={() => setSelected('visa')}
        >
          <VisaIcon /> Visa
        </button>
        <button
          className={`tab-button ${selected === 'bitcoin' ? 'active' : ''}`}
          onClick={() => setSelected('bitcoin')}
        >
          <BitcoinIcon /> Bitcoin
        </button>
      </div>
      <div>{renderProvision()}</div>
    </div>
  );
};

export default PaymentsTab;
