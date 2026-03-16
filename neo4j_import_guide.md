# Neo4j 导入指南（V2.5-B）

本目录基于 `element_material_device_industry_matrix_v2_5_b.xlsx` 导出，目标是把 **元素—材料—器件—系统—产业链 + 战略信号/时钟 + 溯源** 直接导入 Neo4j。

## 1. 文件清单与规模

| 文件 | 类型 | 行数 |
|---|---:|---:|
| nodes_element.csv | node | 49 |
| nodes_cluster.csv | node | 40 |
| nodes_function_position.csv | node | 126 |
| nodes_material.csv | node | 18 |
| nodes_device.csv | node | 12 |
| nodes_system.csv | node | 7 |
| nodes_industry_node.csv | node | 7 |
| nodes_strategic_signal.csv | node | 154 |
| nodes_strategic_clock.csv | node | 40 |
| nodes_source.csv | node | 19 |
| nodes_alt_material_option.csv | node | 67 |
| nodes_alt_route_option.csv | node | 53 |
| nodes_alt_system_option.csv | node | 39 |
| edges_belongs_to.csv | edge | 98 |
| edges_enables.csv | edge | 51 |
| edges_used_in.csv | edge | 18 |
| edges_part_of.csv | edge | 13 |
| edges_deployed_in.csv | edge | 10 |
| edges_sub_material.csv | edge | 71 |
| edges_sub_route.csv | edge | 53 |
| edges_sub_system.csv | edge | 52 |
| edges_affects.csv | edge | 194 |
| edges_supported_by.csv | edge | 221 |

## 2. 节点主键

| 节点文件 | 主键字段 |
|---|---|
| nodes_element.csv | element_id |
| nodes_cluster.csv | cluster_key |
| nodes_function_position.csv | function_id |
| nodes_material.csv | material_id |
| nodes_device.csv | device_id |
| nodes_system.csv | system_id |
| nodes_industry_node.csv | industry_node_id |
| nodes_strategic_signal.csv | signal_id |
| nodes_strategic_clock.csv | clock_id |
| nodes_source.csv | source_id |
| nodes_alt_material_option.csv | alt_material_id |
| nodes_alt_route_option.csv | alt_route_id |
| nodes_alt_system_option.csv | alt_system_id |

## 3. 边起终点字段

所有边文件统一使用：
- `start_id`
- `end_id`
- `start_label`
- `end_label`
- `relationship_type`

具体映射如下：

| 边文件 | 起点字段 | 终点字段 | 起点标签 | 终点标签 |
|---|---|---|---|---|
| edges_belongs_to.csv | start_id | end_id | Element | Cluster |
| edges_enables.csv | start_id | end_id | FunctionPosition | Material/Device |
| edges_used_in.csv | start_id | end_id | Material | Device |
| edges_part_of.csv | start_id | end_id | Device | System |
| edges_deployed_in.csv | start_id | end_id | System | IndustryNode |
| edges_sub_material.csv | start_id | end_id | FunctionPosition | AltMaterialOption |
| edges_sub_route.csv | start_id | end_id | FunctionPosition | AltRouteOption |
| edges_sub_system.csv | start_id | end_id | FunctionPosition | AltSystemOption |
| edges_affects.csv | start_id | end_id | StrategicSignal/StrategicClock | Cluster |
| edges_supported_by.csv | start_id | end_id | StrategicSignal/StrategicClock | Source |

## 4. 推荐导入顺序

### 第一步：创建约束
```cypher
CREATE CONSTRAINT element_id IF NOT EXISTS FOR (n:Element) REQUIRE n.element_id IS UNIQUE;
CREATE CONSTRAINT cluster_key IF NOT EXISTS FOR (n:Cluster) REQUIRE n.cluster_key IS UNIQUE;
CREATE CONSTRAINT function_id IF NOT EXISTS FOR (n:FunctionPosition) REQUIRE n.function_id IS UNIQUE;
CREATE CONSTRAINT material_id IF NOT EXISTS FOR (n:Material) REQUIRE n.material_id IS UNIQUE;
CREATE CONSTRAINT device_id IF NOT EXISTS FOR (n:Device) REQUIRE n.device_id IS UNIQUE;
CREATE CONSTRAINT system_id IF NOT EXISTS FOR (n:System) REQUIRE n.system_id IS UNIQUE;
CREATE CONSTRAINT industry_node_id IF NOT EXISTS FOR (n:IndustryNode) REQUIRE n.industry_node_id IS UNIQUE;
CREATE CONSTRAINT signal_id IF NOT EXISTS FOR (n:StrategicSignal) REQUIRE n.signal_id IS UNIQUE;
CREATE CONSTRAINT clock_id IF NOT EXISTS FOR (n:StrategicClock) REQUIRE n.clock_id IS UNIQUE;
CREATE CONSTRAINT source_id IF NOT EXISTS FOR (n:Source) REQUIRE n.source_id IS UNIQUE;
CREATE CONSTRAINT alt_material_id IF NOT EXISTS FOR (n:AltMaterialOption) REQUIRE n.alt_material_id IS UNIQUE;
CREATE CONSTRAINT alt_route_id IF NOT EXISTS FOR (n:AltRouteOption) REQUIRE n.alt_route_id IS UNIQUE;
CREATE CONSTRAINT alt_system_id IF NOT EXISTS FOR (n:AltSystemOption) REQUIRE n.alt_system_id IS UNIQUE;
```

### 第二步：导入节点
建议顺序：
1. `nodes_source.csv`
2. `nodes_cluster.csv`
3. `nodes_element.csv`
4. `nodes_function_position.csv`
5. `nodes_material.csv`
6. `nodes_device.csv`
7. `nodes_system.csv`
8. `nodes_industry_node.csv`
9. `nodes_strategic_signal.csv`
10. `nodes_strategic_clock.csv`
11. `nodes_alt_material_option.csv`
12. `nodes_alt_route_option.csv`
13. `nodes_alt_system_option.csv`

示例（Element）：
```cypher
LOAD CSV WITH HEADERS FROM 'file:///nodes_element.csv' AS row
MERGE (n:Element {{element_id: row.element_id}})
SET n.symbol = row.symbol,
    n.element_name_cn = row.element_name_cn,
    n.element_name_en = row.element_name_en,
    n.atomic_number = toInteger(row.atomic_number),
    n.period_group_class = row.period_group_class,
    n.primary_domain = row.primary_domain,
    n.primary_domain_cn = row.primary_domain_cn,
    n.criticality_level = row.criticality_level,
    n.cluster_membership_count = toInteger(row.cluster_membership_count),
    n.cluster_keys = row.cluster_keys,
    n.source_origins = row.source_origins,
    n.notes = row.notes;
```

示例（Source）：
```cypher
LOAD CSV WITH HEADERS FROM 'file:///nodes_source.csv' AS row
MERGE (n:Source {{source_id: row.source_id}})
SET n.file_name = row.file_name,
    n.source_role = row.source_role,
    n.parse_status = row.parse_status,
    n.integrated_tables = row.integrated_tables,
    n.note = row.note,
    n.external_source_url = row.external_source_url,
    n.publisher = row.publisher,
    n.publication_date = row.publication_date,
    n.source_authority_score = CASE WHEN row.source_authority_score = '' THEN null ELSE toFloat(row.source_authority_score) END;
```

### 第三步：导入关系
建议顺序：
1. `edges_belongs_to.csv`
2. `edges_enables.csv`
3. `edges_used_in.csv`
4. `edges_part_of.csv`
5. `edges_deployed_in.csv`
6. `edges_sub_material.csv`
7. `edges_sub_route.csv`
8. `edges_sub_system.csv`
9. `edges_affects.csv`
10. `edges_supported_by.csv`

示例（BELONGS_TO）：
```cypher
LOAD CSV WITH HEADERS FROM 'file:///edges_belongs_to.csv' AS row
MATCH (a:Element {{element_id: row.start_id}})
MATCH (b:Cluster {{cluster_key: row.end_id}})
MERGE (a)-[r:BELONGS_TO {{rel_id: row.rel_id}}]->(b)
SET r.role = row.role,
    r.note = row.note;
```

示例（SUPPORTED_BY）：
```cypher
LOAD CSV WITH HEADERS FROM 'file:///edges_supported_by.csv' AS row
CALL {{
  WITH row
  MATCH (a:StrategicSignal {{signal_id: row.start_id}})
  MATCH (b:Source {{source_id: row.end_id}})
  MERGE (a)-[r:SUPPORTED_BY {{rel_id: row.rel_id}}]->(b)
  SET r.evidence_type = row.evidence_type,
      r.evidence_date = row.evidence_date,
      r.confidence_score = CASE WHEN row.confidence_score = '' THEN null ELSE toFloat(row.confidence_score) END,
      r.confidence_band = row.confidence_band
}}
CALL {{
  WITH row
  MATCH (a:StrategicClock {{clock_id: row.start_id}})
  MATCH (b:Source {{source_id: row.end_id}})
  MERGE (a)-[r:SUPPORTED_BY {{rel_id: row.rel_id}}]->(b)
  SET r.evidence_type = row.evidence_type,
      r.evidence_date = row.evidence_date,
      r.confidence_score = CASE WHEN row.confidence_score = '' THEN null ELSE toFloat(row.confidence_score) END,
      r.confidence_band = row.confidence_band
}}
RETURN count(*);
```

## 5. 关系语义说明

- `BELONGS_TO`：元素属于某个簇。
- `ENABLES`：功能位使能材料或器件。
- `USED_IN`：材料进入器件。
- `PART_OF`：器件构成系统的一部分。
- `DEPLOYED_IN`：系统落入产业链节点。
- `SUB_MATERIAL / SUB_ROUTE / SUB_SYSTEM`：功能位替代关系。
- `AFFECTS`：战略信号或战略时钟影响某个簇。
- `SUPPORTED_BY`：战略信号/时钟由来源节点支撑。

> 注：`REL_DEVICE_SYSTEM` 原表中的 `DEPLOYED_IN` 在图导入版中被统一翻译为 `PART_OF`，因为器件相对于系统更适合作为组成关系。
> 注：`REL_SYSTEM_INDUSTRY` 原表中的 `LOCATED_IN / DEPENDS_ON` 在图导入版中统一落为 `DEPLOYED_IN`，原始关系类型保留在 `original_relation_type` 属性中。

## 6. 三条示例查询语句

### 查询 1：某元素所在簇的所有战略信号及证据来源
```cypher
MATCH (e:Element {{symbol:'Ga'}})-[:BELONGS_TO]->(c:Cluster)<-[:AFFECTS]-(s:StrategicSignal)
OPTIONAL MATCH (s)-[:SUPPORTED_BY]->(src:Source)
RETURN e.symbol, c.cluster_name, s.signal_type, s.signal_desc, s.confidence_band, src.file_name, src.external_source_url
ORDER BY s.signal_strength DESC;
```

### 查询 2：某器件回溯到材料、功能位、元素簇
```cypher
MATCH (m:Material)-[:USED_IN]->(d:Device {{device_id:'DV_SIC_MOSFET'}})
OPTIONAL MATCH (fp:FunctionPosition)-[:ENABLES]->(m)
OPTIONAL MATCH (fp)-[:BELONGS_TO|PART_OF*0..1]->(c:Cluster)
RETURN d.device_name_cn, m.material_name_cn, fp.function_name, c.cluster_name
ORDER BY m.material_name_cn;
```

### 查询 3：检索可立即替代（NOW）的材料替代路径
```cypher
MATCH (fp:FunctionPosition)-[r:SUB_MATERIAL]->(alt:AltMaterialOption)
WHERE r.feasibility = 'NOW' AND (r.perf_loss_pct IS NULL OR toFloat(r.perf_loss_pct) <= 20)
RETURN fp.function_id, fp.function_name, alt.alt_material, r.perf_loss_pct, r.cost_factor, r.confidence_band
ORDER BY r.perf_loss_pct ASC;
```

## 7. 完整性检查

另附 `referential_integrity_check.csv`，用于快速确认所有边文件的起点/终点在节点表中都能找到。
