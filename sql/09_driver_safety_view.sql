CREATE OR REPLACE VIEW driver_safety_view AS
SELECT
    d.driver_id,
    d.first_name || ' ' || d.last_name AS driver_name,
    COUNT(si.incident_id) AS total_incidents,
    SUM(
        COALESCE(si.claim_amount,0)
        + COALESCE(si.vehicle_damage_cost,0)
        + COALESCE(si.cargo_damage_cost,0)
    ) AS total_incident_cost,
    SUM(
        CASE
            WHEN si.preventable_flag = TRUE THEN 1
            ELSE 0
        END
    ) AS preventable_incidents,
    SUM(
        CASE
            WHEN si.at_fault_flag = TRUE THEN 1
            ELSE 0
        END
    ) AS at_fault_incidents
FROM drivers d
LEFT JOIN safety_incidents si
    ON d.driver_id = si.driver_id
GROUP BY
    d.driver_id,
    d.first_name,
    d.last_name;

SELECT
    driver_id,
    driver_name,
    total_incidents,
    total_incident_cost,
    preventable_incidents,
    at_fault_incidents
FROM driver_safety_view
ORDER BY total_incident_cost DESC
LIMIT 10;

select *
from driver_safety_view dsv
limit 5;