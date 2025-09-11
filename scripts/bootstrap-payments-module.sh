#!/bin/bash

echo "🔧 Starting Payments module bootstrap..."

# Scaffold backend controller
mkdir -p finance-wallet-onboarding/backend/controllers
cat <<EOF > finance-wallet-onboarding/backend/controllers/payments.js
exports.provisionPayment = (req, res) => {
  const { userId, cardType, currency, provisionMode } = req.body;
  console.log(\`Provisioning \${cardType} for \${userId} in \${currency} via \${provisionMode}\`);
  res.status(200).json({ status: "success", shimmer: true });
};
EOF

# Scaffold backend route
mkdir -p finance-wallet-onboarding/backend/routes
cat <<EOF > finance-wallet-onboarding/backend/routes/payments.js
const express = require('express');
const router = express.Router();
const { provisionPayment } = require('../controllers/payments');

router.post('/api/payments/:type', provisionPayment);

module.exports = router;
EOF

# Scaffold GUI components
mkdir -p src/components/Payments src/components/icons src/components/Tabs

# BitcoinProvision.tsx
cat <<EOF > src/components/Payments/BitcoinProvision.tsx
import React from 'react';
const BitcoinProvision = () => (
  <div><h3>🪙 Bitcoin Provisioning</h3><p>Provision wallet or Lightning invoice.</p></div>
);
export default BitcoinProvision;
EOF

# MastercardProvision.tsx
cat <<EOF > src/components/Payments/MastercardProvision.tsx
import React from 'react';
const MastercardProvision = () => (
  <div><h3>💳 Mastercard Provisioning</h3><p>Provision stablecoin-backed card.</p></div>
);
export default MastercardProvision;
EOF

# VisaProvision.tsx
cat <<EOF > src/components/Payments/VisaProvision.tsx
import React from 'react';
const VisaProvision = () => (
  <div><h3>🧾 Visa Provisioning</h3><p>Provision tap-to-lease credential.</p></div>
);
export default VisaProvision;
EOF

# Icons
cat <<EOF > src/components/icons/Bitcoin.tsx
import React from 'react';
const BitcoinIcon = () => <span role="img" aria-label="Bitcoin">🪙</span>;
export default BitcoinIcon;
EOF

cat <<EOF > src/components/icons/Mastercard.tsx
import React from 'react';
const MastercardIcon = () => <span role="img" aria-label="Mastercard">💳</span>;
export default MastercardIcon;
EOF

cat <<EOF > src/components/icons/Visa.tsx
import React from 'react';
const VisaIcon = () => <span role="img" aria-label="Visa">🧾</span>;
export default VisaIcon;
EOF

# PaymentsTab.tsx
cat <<EOF > src/components/Tabs/PaymentsTab.tsx
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
      case 'mastercard': return <MastercardProvision />;
      case 'visa': return <VisaProvision />;
      case 'bitcoin': return <BitcoinProvision />;
      default: return null;
    }
  };
  return (
    <div>
      <h2>💳 Payments & Provisioning</h2>
      <div>
        <button onClick={() => setSelected('mastercard')}><MastercardIcon /> Mastercard</button>
        <button onClick={() => setSelected('visa')}><VisaIcon /> Visa</button>
        <button onClick={() => setSelected('bitcoin')}><BitcoinIcon /> Bitcoin</button>
      </div>
      {renderProvision()}
    </div>
  );
};

export default PaymentsTab;
EOF

# Codex provisioning template
mkdir -p codex/templates
cat <<EOF > codex/templates/provisioning.yaml
- event: "Payments Module Initialized"
  timestamp: "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  components:
    - MastercardProvision
    - VisaProvision
    - BitcoinProvision
  shimmer: true
EOF

# Tab registry injection (dynamic router support)
mkdir -p src/config
cat <<EOF > src/config/tabs.config.ts
import PaymentsTab from '../components/Tabs/PaymentsTab';

export const tabRegistry = [
  { label: 'Documentation', component: <div>Docs go here</div> },
  { label: 'Automation Scripts', component: <div>Scripts go here</div> },
  { label: 'Assets & Crests', component: <div>Crests go here</div> },
  { label: 'Payments', component: <PaymentsTab /> }
];
EOF

echo "✅ Payments module scaffolded and integrated into tab registry."
# Note: Remember to integrate the new route in your main Express app file (e.g., app.js or server.js)