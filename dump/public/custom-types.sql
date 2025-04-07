SET search_path = "public";

-- Enum: Enrichment Type
CREATE TYPE "Enrichment Type" AS ENUM (
  'records',
  'research'
);

-- Enum: Enrichment Status
CREATE TYPE "Enrichment Status" AS ENUM (
  'pending',
  'complete',
  'processing',
  'initial_request_sent',
  'in_conversation',
  'waiting_for_output',
  'failure'
);

-- Enum: Custom Column Types
CREATE TYPE "Custom Column Types" AS ENUM (
  'note',
  'tag',
  'smart'
);

-- Enum: Data Source
CREATE TYPE "Data Source" AS ENUM (
  'annual_budgets',
  'meeting_minutes',
  'purchase_orders',
  'online_research',
  'contacts',
  'procurement_guidelines',
  'strategic_plans',
  'news',
  'rfps',
  'grants',
  'legislation',
  'intent'
);

-- Enum: Rerun Frequency
CREATE TYPE "Rerun Frequency" AS ENUM (
  'daily',
  'weekly',
  'monthly',
  'none'
);

-- Enum: Output Format
CREATE TYPE "Output Format" AS ENUM (
  'text',
  'number',
  'boolean'
);

-- Enum: foia_preferred_method
CREATE TYPE foia_preferred_method AS ENUM (
  'Email',
  'Portal',
  'Web Form',
  'Email Form',
  'Unknown',
  'Skip',
  'Fax',
  'Mail',
  'Online Webscrape'
);
