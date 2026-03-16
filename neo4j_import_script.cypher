# Neo4j Import Script
# ============================================
# 使用说明：
# 1. 将 neo4j_import_v2_5_b 文件夹下的所有 CSV 文件复制到 Neo4j 的 import 文件夹
#    - Windows: C:\neo4j\neo4j-community-版本号\import\
#    - Linux/Mac: /var/lib/neo4j/import/ 或 ~/neo4j/import/
# 2. 打开 Neo4j Browser (http://localhost:7474)
# 3. 依次执行以下各部分的 Cypher 语句
# ============================================

# ============================================
# 第一部分：创建约束 (13个节点类型)
# ============================================

// 创建约束 - Element
CREATE CONSTRAINT element_id IF NOT EXISTS FOR (n:Element) REQUIRE n.element_id IS UNIQUE;

// 创建约束 - Cluster
CREATE CONSTRAINT cluster_key IF NOT EXISTS FOR (n:Cluster) REQUIRE n.cluster_key IS UNIQUE;

// 创建约束 - FunctionPosition
CREATE CONSTRAINT function_id IF NOT EXISTS FOR (n:FunctionPosition) REQUIRE n.function_id IS UNIQUE;

// 创建约束 - Material
CREATE CONSTRAINT material_id IF NOT EXISTS FOR (n:Material) REQUIRE n.material_id IS UNIQUE;

// 创建约束 - Device
CREATE CONSTRAINT device_id IF NOT EXISTS FOR (n:Device) REQUIRE n.device_id IS UNIQUE;

// 创建约束 - System
CREATE CONSTRAINT system_id IF NOT EXISTS FOR (n:System) REQUIRE n.system_id IS UNIQUE;

// 创建约束 - IndustryNode
CREATE CONSTRAINT industry_node_id IF NOT EXISTS FOR (n:IndustryNode) REQUIRE n.industry_node_id IS UNIQUE;

// 创建约束 - StrategicSignal
CREATE CONSTRAINT signal_id IF NOT EXISTS FOR (n:StrategicSignal) REQUIRE n.signal_id IS UNIQUE;

// 创建约束 - StrategicClock
CREATE CONSTRAINT clock_id IF NOT EXISTS FOR (n:StrategicClock) REQUIRE n.clock_id IS UNIQUE;

// 创建约束 - Source
CREATE CONSTRAINT source_id IF NOT EXISTS FOR (n:Source) REQUIRE n.source_id IS UNIQUE;

// 创建约束 - AltMaterialOption
CREATE CONSTRAINT alt_material_id IF NOT EXISTS FOR (n:AltMaterialOption) REQUIRE n.alt_material_id IS UNIQUE;

// 创建约束 - AltRouteOption
CREATE CONSTRAINT alt_route_id IF NOT EXISTS FOR (n:AltRouteOption) REQUIRE n.alt_route_id IS UNIQUE;

// 创建约束 - AltSystemOption
CREATE CONSTRAINT alt_system_id IF NOT EXISTS FOR (n:AltSystemOption) REQUIRE n.alt_system_id IS UNIQUE;


# ============================================
# 第二部分：导入节点 (按依赖顺序)
# ============================================

// -----------------------------------------
// 1. 导入 Source 节点 (19行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///nodes_source.csv' AS row
MERGE (n:Source {source_id: row.source_id})
SET n.file_name = row.file_name,
    n.source_role = row.source_role,
    n.parse_status = row.parse_status,
    n.integrated_tables = row.integrated_tables,
    n.note = row.note,
    n.external_source_url = row.external_source_url,
    n.publisher = row.publisher,
    n.publication_date = row.publication_date,
    n.source_authority_score = CASE WHEN row.source_authority_score = '' THEN null ELSE toFloat(row.source_authority_score) END;

// -----------------------------------------
// 2. 导入 Cluster 节点 (40行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///nodes_cluster.csv' AS row
MERGE (n:Cluster {cluster_key: row.cluster_key})
SET n.cluster_name = row.cluster_name,
    n.cluster_name_cn = row.cluster_name_cn,
    n.cluster_family = row.cluster_family,
    n.element_count = toInteger(row.element_count),
    n.elements = row.elements,
    n.primary_domain = row.primary_domain,
    n.primary_domain_cn = row.primary_domain_cn,
    n.criticality_summary = row.criticality_summary,
    n.related_systems = row.related_systems,
    n.note = row.note;

// -----------------------------------------
// 3. 导入 Element 节点 (49行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///nodes_element.csv' AS row
MERGE (n:Element {element_id: row.element_id})
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
    n.notes = row.note;

// -----------------------------------------
// 4. 导入 FunctionPosition 节点 (126行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///nodes_function_position.csv' AS row
MERGE (n:FunctionPosition {function_id: row.function_id})
SET n.function_name = row.function_name,
    n.function_name_cn = row.function_name_cn,
    n.function_category = row.function_category,
    n.function_category_cn = row.function_category_cn,
    n.domain = row.domain,
    n.domain_cn = row.domain_cn,
    n.related_elements = row.related_elements,
    n.related_clusters = row.related_clusters,
    n.related_materials = row.related_materials,
    n.related_devices = row.related_devices,
    n.related_systems = row.related_systems,
    n.key_properties = row.key_properties,
    n.performance_metrics = row.performance_metrics,
    n.criticality_notes = row.criticality_notes,
    n.source_refs = row.source_refs;

// -----------------------------------------
// 5. 导入 Material 节点 (18行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///nodes_material.csv' AS row
MERGE (n:Material {material_id: row.material_id})
SET n.material_name = row.material_name,
    n.material_name_cn = row.material_name_cn,
    n.material_category = row.material_category,
    n.form = row.form,
    n.key_properties = row.key_properties,
    n.primary_applications = row.primary_applications,
    n.related_elements = row.related_elements,
    n.related_function_positions = row.related_function_positions,
    n.sustainability_notes = row.sustainability_notes,
    n.criticality = row.criticality;

// -----------------------------------------
// 6. 导入 Device 节点 (12行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///nodes_device.csv' AS row
MERGE (n:Device {device_id: row.device_id})
SET n.device_name = row.device_name,
    n.device_name_cn = row.device_name_cn,
    n.device_category = row.device_category,
    n.core_material = row.core_material,
    n.key_components = row.key_components,
    n.applications = row.applications,
    n.performance_tier = row.performance_tier,
    n.criticality = row.criticality,
    n.related_systems = row.related_systems;

// -----------------------------------------
// 7. 导入 System 节点 (7行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///nodes_system.csv' AS row
MERGE (n:System {system_id: row.system_id})
SET n.system_name = row.system_name,
    n.system_name_cn = row.system_name_cn,
    n.system_category = row.system_category,
    n.key_devices = row.key_devices,
    n.applications = row.applications,
    n.industry_nodes = row.industry_nodes,
    n.criticality = row.criticality;

// -----------------------------------------
// 8. 导入 IndustryNode 节点 (7行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///nodes_industry_node.csv' AS row
MERGE (n:IndustryNode {industry_node_id: row.industry_node_id})
SET n.node_name = row.node_name,
    n.node_name_cn = row.node_name_cn,
    n.node_category = row.node_category,
    n.description = row.description,
    n.related_systems = row.related_systems;

// -----------------------------------------
// 9. 导入 StrategicSignal 节点 (154行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///nodes_strategic_signal.csv' AS row
MERGE (n:StrategicSignal {signal_id: row.signal_id})
SET n.signal_type = row.signal_type,
    n.signal_desc = row.signal_desc,
    n.signal_strength = row.signal_strength,
    n.confidence_band = row.confidence_band,
    n.time_horizon = row.time_horizon,
    n.affected_clusters = row.affected_clusters,
    n.affected_elements = row.affected_elements,
    n.related_sources = row.related_sources,
    n.note = row.note;

// -----------------------------------------
// 10. 导入 StrategicClock 节点 (40行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///nodes_strategic_clock.csv' AS row
MERGE (n:StrategicClock {clock_id: row.clock_id})
SET n.clock_type = row.clock_type,
    n.clock_desc = row.clock_desc,
    n.milestone_year = row.milestone_year,
    n.time_horizon = row.time_horizon,
    n.affected_clusters = row.affected_clusters,
    n.affected_elements = row.affected_elements,
    n.related_sources = row.related_sources,
    n.note = row.note;

// -----------------------------------------
// 11. 导入 AltMaterialOption 节点 (67行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///nodes_alt_material_option.csv' AS row
MERGE (n:AltMaterialOption {alt_material_id: row.alt_material_id})
SET n.alt_material = row.alt_material,
    n.original_material = row.original_material,
    n.feasibility = row.feasibility,
    n.perf_loss_pct = CASE WHEN row.perf_loss_pct = '' THEN null ELSE toFloat(row.perf_loss_pct) END,
    n.cost_factor = row.cost_factor,
    n.maturity = row.maturity,
    n.key_challenges = row.key_challenges,
    n.supply_chain_status = row.supply_chain_status;

// -----------------------------------------
// 12. 导入 AltRouteOption 节点 (53行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///nodes_alt_route_option.csv' AS row
MERGE (n:AltRouteOption {alt_route_id: row.alt_route_id})
SET n.alt_route = row.alt_route,
    n.original_route = row.original_route,
    n.feasibility = row.feasibility,
    n.cost_impact = row.cost_impact,
    n.technology_readiness = row.technology_readiness,
    n.key_differences = row.key_differences;

// -----------------------------------------
// 13. 导入 AltSystemOption 节点 (39行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///nodes_alt_system_option.csv' AS row
MERGE (n:AltSystemOption {alt_system_id: row.alt_system_id})
SET n.alt_system = row.alt_system,
    n.original_system = row.original_system,
    n.feasibility = row.feasibility,
    n.performance_gain = row.performance_gain,
    n.cost_implications = row.cost_implications,
    n.maturity_level = row.maturity_level;


# ============================================
# 第三部分：导入边/关系 (按依赖顺序)
# ============================================

// -----------------------------------------
// 1. 导入 BELONGS_TO 关系 (98行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///edges_belongs_to.csv' AS row
MATCH (a:Element {element_id: row.start_id})
MATCH (b:Cluster {cluster_key: row.end_id})
MERGE (a)-[r:BELONGS_TO {rel_id: row.rel_id}]->(b)
SET r.role = row.role,
    r.note = row.note;

// -----------------------------------------
// 2. 导入 ENABLES 关系 (51行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///edges_enables.csv' AS row
CALL {
  WITH row
  MATCH (a:FunctionPosition {function_id: row.start_id})
  MATCH (b:Material {material_id: row.end_id})
  MERGE (a)-[r:ENABLES {rel_id: row.rel_id}]->(b)
  SET r.note = row.note
}
CALL {
  WITH row
  MATCH (a:FunctionPosition {function_id: row.start_id})
  MATCH (b:Device {device_id: row.end_id})
  MERGE (a)-[r:ENABLES {rel_id: row.rel_id}]->(b)
  SET r.note = row.note
}
RETURN count(*);

// -----------------------------------------
// 3. 导入 USED_IN 关系 (18行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///edges_used_in.csv' AS row
MATCH (a:Material {material_id: row.start_id})
MATCH (b:Device {device_id: row.end_id})
MERGE (a)-[r:USED_IN {rel_id: row.rel_id}]->(b)
SET r.usage_type = row.usage_type,
    r.note = row.note;

// -----------------------------------------
// 4. 导入 PART_OF 关系 (13行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///edges_part_of.csv' AS row
MATCH (a:Device {device_id: row.start_id})
MATCH (b:System {system_id: row.end_id})
MERGE (a)-[r:PART_OF {rel_id: row.rel_id}]->(b)
SET r.role = row.role,
    r.note = row.note;

// -----------------------------------------
// 5. 导入 DEPLOYED_IN 关系 (10行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///edges_deployed_in.csv' AS row
MATCH (a:System {system_id: row.start_id})
MATCH (b:IndustryNode {industry_node_id: row.end_id})
MERGE (a)-[r:DEPLOYED_IN {rel_id: row.rel_id}]->(b)
SET r.note = row.note;

// -----------------------------------------
// 6. 导入 SUB_MATERIAL 关系 (71行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///edges_sub_material.csv' AS row
MATCH (a:FunctionPosition {function_id: row.start_id})
MATCH (b:AltMaterialOption {alt_material_id: row.end_id})
MERGE (a)-[r:SUB_MATERIAL {rel_id: row.rel_id}]->(b)
SET r.feasibility = row.feasibility,
    r.perf_loss_pct = CASE WHEN row.perf_loss_pct = '' THEN null ELSE toFloat(row.perf_loss_pct) END,
    r.cost_factor = row.cost_factor,
    r.confidence_band = row.confidence_band,
    r.note = row.note;

// -----------------------------------------
// 7. 导入 SUB_ROUTE 关系 (53行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///edges_sub_route.csv' AS row
MATCH (a:FunctionPosition {function_id: row.start_id})
MATCH (b:AltRouteOption {alt_route_id: row.end_id})
MERGE (a)-[r:SUB_ROUTE {rel_id: row.rel_id}]->(b)
SET r.feasibility = row.feasibility,
    r.cost_impact = row.cost_impact,
    r.note = row.note;

// -----------------------------------------
// 8. 导入 SUB_SYSTEM 关系 (52行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///edges_sub_system.csv' AS row
MATCH (a:FunctionPosition {function_id: row.start_id})
MATCH (b:AltSystemOption {alt_system_id: row.end_id})
MERGE (a)-[r:SUB_SYSTEM {rel_id: row.rel_id}]->(b)
SET r.feasibility = row.feasibility,
    r.performance_gain = row.performance_gain,
    r.note = row.note;

// -----------------------------------------
// 9. 导入 AFFECTS 关系 (194行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///edges_affects.csv' AS row
CALL {
  WITH row
  MATCH (a:StrategicSignal {signal_id: row.start_id})
  MATCH (b:Cluster {cluster_key: row.end_id})
  MERGE (a)-[r:AFFECTS {rel_id: row.rel_id}]->(b)
  SET r.impact_type = row.impact_type,
      r.impact_strength = row.impact_strength,
      r.note = row.note
}
CALL {
  WITH row
  MATCH (a:StrategicClock {clock_id: row.start_id})
  MATCH (b:Cluster {cluster_key: row.end_id})
  MERGE (a)-[r:AFFECTS {rel_id: row.rel_id}]->(b)
  SET r.impact_type = row.impact_type,
      r.impact_strength = row.impact_strength,
      r.note = row.note
}
RETURN count(*);

// -----------------------------------------
// 10. 导入 SUPPORTED_BY 关系 (221行)
// -----------------------------------------
LOAD CSV WITH HEADERS FROM 'file:///edges_supported_by.csv' AS row
CALL {
  WITH row
  MATCH (a:StrategicSignal {signal_id: row.start_id})
  MATCH (b:Source {source_id: row.end_id})
  MERGE (a)-[r:SUPPORTED_BY {rel_id: row.rel_id}]->(b)
  SET r.evidence_type = row.evidence_type,
      r.evidence_date = row.evidence_date,
      r.confidence_score = CASE WHEN row.confidence_score = '' THEN null ELSE toFloat(row.confidence_score) END,
      r.confidence_band = row.confidence_band
}
CALL {
  WITH row
  MATCH (a:StrategicClock {clock_id: row.start_id})
  MATCH (b:Source {source_id: row.end_id})
  MERGE (a)-[r:SUPPORTED_BY {rel_id: row.rel_id}]->(b)
  SET r.evidence_type = row.evidence_type,
      r.evidence_date = row.evidence_date,
      r.confidence_score = CASE WHEN row.confidence_score = '' THEN null ELSE toFloat(row.confidence_score) END,
      r.confidence_band = row.confidence_band
}
RETURN count(*);


# ============================================
# 验证查询
# ============================================

// 查看节点统计
MATCH (n)
RETURN labels(n)[0] AS node_type, count(*) AS count
ORDER BY count DESC;

// 查看关系统计
MATCH ()-[r]->()
RETURN type(r) AS relationship_type, count(*) AS count
ORDER BY count DESC;
