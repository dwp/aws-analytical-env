DROP TABLE IF EXISTS ${hivevar:spo_unredacted_db}.tdb_abandoned_historic_data;

CREATE EXTERNAL TABLE ${hivevar:spo_unredacted_db}.tdb_abandoned_historic_data
(
 `sl_ssl` string,
 `calendar_date` date,
 `call_business_group_region_name` string,
 `call_business_group_site_name` string,
 `time_to_abandon_in_queue` double,
 `maximum_time_to_abandon` double,
 `maximum_time_to_answer` double,
 `calls_abandoned_in_ivr_aa` double,
 `calls_offered` double,
 `number_of_calls_abandoned_from_agent_queue` double,
 `number_of_short_abandoned_calls_at_queue` double,
 `number_of_calls_answered_sl` double,
 `number_of_calls_answered_in_20_seconds` double,
 `number_of_calls_answered_in_30_seconds` double,
 `number_of_calls_answered_in_45_seconds` double,
 `number_of_calls_answered_in_60_seconds` double,
 `number_of_calls_answered_in_90_seconds` double,
 `time_to_answer_inbound_calls` double,
 `number_of_nvr_technical_failure` double,
 `number_of_nvr_detection_partial` double,
 `number_of_nvr_no_speech_input` double,
 `number_of_nvr_detection_failed` double,
 `number_of_nvr_successful_id` double,
 `number_of_nvr_inbound_calls` double,
 `calls_abandoned_at_entry` double,
 `number_of_nvr_failures` double
 )
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '${hivevar:s3_prefix}/tdb_abandoned';


DROP TABLE IF EXISTS ${hivevar:spo_unredacted_db}.tdb_abandoned;

CREATE TABLE ${hivevar:spo_unredacted_db}.tdb_abandoned AS SELECT * FROM ${hivevar:spo_unredacted_db}.tdb_abandoned_historic_data;

DROP TABLE IF EXISTS ${hivevar:spo_unredacted_db}.tdb_aux_historic_data;

CREATE EXTERNAL TABLE ${hivevar:spo_unredacted_db}.tdb_aux_historic_data
(
 `agent_id` double,
 `agent_business_group_site_name` string,
 `agent_business_group_region_name` string,
 `calendar_date` date,
 `agent_business_group_sub_segment` string,
 `business_group_site_operation_name` string,
 `business_group_site_team_name` string,
 `agent_name` string,
 `std_non_customer_related_aux_time` double,
 `std_learning_development_aux_time` double,
 `total_agent_logged_in_time` double,
 `std_lunch_aux_time` double,
 `std_non_telephony_aux_time` double,
 `std_telephony_aux_time` double,
 `std_break_aux_time` double,
 `std_communications_aux_time` double,
 `number_of_logins` double,
 `std_telephony_aux_count` double,
 `std_non_telephony_aux_count` double,
 `std_lunch_aux_count` double,
 `std_break_aux_count` double,
 `std_non_customer_related_aux_count` double,
 `std_learning_development_aux_count` double,
 `std_communications_aux_count` double,
 `std_outbound_aux_time` double,
 `std_outbound_aux_count` double,
 `acw_state_time` double,
 `dial_state_time` double,
 `std_acw_aux_time` double,
 `acw_state_count` double
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '${hivevar:s3_prefix}/tdb_aux';



DROP TABLE IF EXISTS ${hivevar:spo_unredacted_db}.tdb_aux;

CREATE TABLE ${hivevar:spo_unredacted_db}.tdb_aux AS SELECT * FROM ${hivevar:spo_unredacted_db}.tdb_aux_historic_data;



DROP TABLE IF EXISTS ${hivevar:spo_unredacted_db}.tdb_avail_historic_data;

CREATE EXTERNAL TABLE ${hivevar:spo_unredacted_db}.tdb_avail_historic_data
(
 `agent_id` double,
 `agent_business_group_name` string,
 `agent_business_group_site_name` string,
 `agent_business_group_region_name` string,
 `calendar_date` date,
 `agent_business_group_sub_segment` string,
 `business_group_site_operation_name` string,
 `business_group_site_team_name` string,
 `agent_name` string,
 `available_time` double,
 `std_default_aux_time` double,
 `std_default_aux_count` double,
 `available_state_count` double
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '${hivevar:s3_prefix}/tdb_avail';


DROP TABLE IF EXISTS ${hivevar:spo_unredacted_db}.tdb_avail;

CREATE TABLE ${hivevar:spo_unredacted_db}.tdb_avail AS SELECT * FROM ${hivevar:spo_unredacted_db}.tdb_avail_historic_data;



DROP TABLE IF EXISTS ${hivevar:spo_unredacted_db}.tdb_calls_historic_data;

CREATE EXTERNAL TABLE ${hivevar:spo_unredacted_db}.tdb_calls_historic_data
(
 `agent_id` double,
 `agent_business_group_site_name` string,
 `agent_business_group_region_name` string,
 `calendar_date` date,
 `sl_ssl` string,
 `agent_business_group_sub_segment` string,
 `business_group_site_operation_name` string,
 `business_group_site_team_name` string,
 `agent_name` string,
 `inbound_ring_time` double,
 `inbound_talk_time` double,
 `inbound_hold_time` double,
 `combined_acw_time` double,
 `outbound_dial_and_ring_time` double,
 `outbound_hold_time` double,
 `inbound_consult_time_made` double,
 `inbound_consult_time_received` double,
 `outbound_consult_time_made` double,
 `outbound_consult_time_received` double,
 `consult_time` double,
 `conference_time` double,
 `inbound_conference_time_made` double,
 `inbound_conference_time_joined` double,
 `inbound_consult_count` double,
 `outbound_calls_agent` string,
 `number_of_calls_answered_agent` double,
 `outbound_consult_count_made` double,
 `outbound_consult_count_received` double,
 `consult_calls_count` double,
 `outbound_conference_time_made` double,
 `outbound_conference_time_joined` double,
 `rona_call_count` double,
 `inbound_calls_held_count` double,
 `outbound_calls_held_count` double,
 `inbound_conference_count_made` double,
 `inbound_conference_count_joined` double,
 `outbound_conference_count_made` double,
 `outbound_conference_count_joined` double,
 `short_answered_call_count` double,
 `inbound_acw_time` double,
 `outbound_acw_time` double,
 `campaign_acw_time` double,
 `campaign_call_handling_time` double
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '${hivevar:s3_prefix}/tdb_calls';


DROP TABLE IF EXISTS ${hivevar:spo_unredacted_db}.tdb_calls;

CREATE TABLE ${hivevar:spo_unredacted_db}.tdb_calls AS SELECT * FROM ${hivevar:spo_unredacted_db}.tdb_calls_historic_data;




DROP TABLE IF EXISTS ${hivevar:spo_unredacted_db}.tdb_cm_calls_historic_data;

CREATE EXTERNAL TABLE ${hivevar:spo_unredacted_db}.tdb_cm_calls_historic_data
(
 `agent_id` int,
 `sl_ssl` string,
 `calendar_date` date,
 `start_time` string,
 `group_name` string,
 `site_name` string,
 `region_name` string,
 `team_name` string,
 `agent_name` string,
 `target_phase_description` string,
 `target_phase_code` int,
 `inbound_talk_time` int,
 `inbound_hold_time` int,
 `inbound_acw_time` int,
 `agent_queue_to_initial_answer_duration` int,
 `inbound_conference_time_made` int,
 `number_of_calls_answered_agent` int,
 `case_manager_answered_calls` int,
 `team_answered_calls` int,
 `national_answered_calls` int,
 `site_answered_calls` int
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '${hivevar:s3_prefix}/tdb_cm_calls';


DROP TABLE IF EXISTS ${hivevar:spo_unredacted_db}.tdb_cm_calls;

CREATE TABLE ${hivevar:spo_unredacted_db}.tdb_cm_calls AS SELECT * FROM ${hivevar:spo_unredacted_db}.tdb_cm_calls_historic_data;

