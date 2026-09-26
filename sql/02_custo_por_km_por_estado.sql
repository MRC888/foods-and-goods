with entregas_por_pedido as (
    -- Agrega antes de juntar ao custo: cada pedido contribuirá uma única vez.
    select
        d.delivery_order_id,
        count(*) as quantidade_entregas,
        sum(d.delivery_distance_meters) / 1000.0 as distancia_pedido_km,
        bool_and(coalesce(dr.driver_modal = 'MOTOBOY', false)) as somente_moto,
        bool_and(coalesce(d.delivery_distance_meters > 0, false)) as distancias_validas
    from "Foods and Goods".deliveries as d
    left join "Foods and Goods".drivers as dr
        on d.driver_id = dr.driver_id
    where d.delivery_status = 'DELIVERED'
    group by d.delivery_order_id
), base as (
    select
        h.hub_state as estado,
        e.*,
        o.order_delivery_cost as custo_pedido,
        e.distancias_validas
            and o.order_delivery_cost is not null
            and o.order_delivery_cost >= 0 as elegivel
    from entregas_por_pedido as e
    join "Foods and Goods".orders as o
        on e.delivery_order_id = o.order_id
    join "Foods and Goods".stores as s
        on o.store_id = s.store_id
    join "Foods and Goods".hubs as h
        on s.hub_id = h.hub_id
    where e.somente_moto
)
select
    estado,
    count(*) as pedidos_somente_moto,
    count(*) filter (where elegivel) as pedidos_com_custo_e_distancia,
    count(*) filter (where not elegivel) as pedidos_excluidos,
    round(100.0 * count(*) filter (where elegivel) / nullif(count(*), 0), 2) as cobertura_pct,
    count(*) filter (where elegivel and custo_pedido = 0) as pedidos_custo_zero,
    count(*) filter (where elegivel and quantidade_entregas > 1) as pedidos_multiplas_entregas,
    round((sum(custo_pedido) filter (where elegivel))::numeric, 2) as custo_total_registrado,
    round((sum(distancia_pedido_km) filter (where elegivel))::numeric, 2) as distancia_total_km,
    round(((sum(custo_pedido) filter (where elegivel)) /
        nullif(sum(distancia_pedido_km) filter (where elegivel), 0))::numeric, 2) as custo_registrado_por_km,
    round((max(distancia_pedido_km) filter (where elegivel))::numeric, 2) as maior_distancia_pedido_km
from base
group by estado
order by custo_registrado_por_km desc;
