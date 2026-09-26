select
    h.hub_state as estado,
    count(*) as entregas_filtradas,
    count(*) filter (where d.delivery_distance_meters is null) as distancias_nulas,
    count(*) filter (where d.delivery_distance_meters <= 0) as distancias_nao_positivas,
    count(*) filter (where d.delivery_distance_meters > 50000) as entregas_acima_50_km,
    round((max(d.delivery_distance_meters) / 1000.0)::numeric, 2) as maior_distancia_km,
    round((percentile_cont(0.5) within group (order by d.delivery_distance_meters) / 1000.0)::numeric, 2) as mediana_km
from "Foods and Goods".deliveries as d
join "Foods and Goods".orders as o on d.delivery_order_id = o.order_id
join "Foods and Goods".stores as s on o.store_id = s.store_id
join "Foods and Goods".hubs as h on s.hub_id = h.hub_id
join "Foods and Goods".drivers as dr on d.driver_id = dr.driver_id
where d.delivery_status = 'DELIVERED'
  and dr.driver_modal = 'MOTOBOY'
group by h.hub_state
order by estado;
