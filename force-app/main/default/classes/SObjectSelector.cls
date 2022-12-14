/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public inherited sharing abstract class SObjectSelector implements iSObjectSelector{
    private static final String LOG_PREFIX      = '[][][SObjectSelector] ';

    private Schema.SObjectType m_SObjectType { get; set; }
    private Map<String, Schema.SObjectField> m_fieldMap { get; set; }

    private Map<String, Schema.SObjectField> fieldMap {
        get {
            if (m_fieldMap == null) {
                m_fieldMap = SchemaHelper.GetDescribe(GetSObjectType()).fields.getMap();
            }
            return m_fieldMap;
        }
    }

    /**
     * Constructor
     * @param  coveredSObject  Schema.SObjectType  SObject the Selector covers
     */
    public SObjectSelector(Schema.SObjectType coveredSObject) { m_SObjectType = coveredSObject; }

    /**
     * The SObjectType covered by the Selector.
     * Value is set through the consuming class constructure by calling super(<SObject>.getSObjectType());
     * @return   SObjectType
     */
    public Schema.SObjectType SObjectType { get { return GetSObjectType(); } }

    /**
     * The SObjectType covered by the Selector.
     * Value is set through the consuming class constructure by calling super(<SObject>.getSObjectType());
     * @return   SObjectType
     */
    public SObjectType GetSObjectType() { return m_SObjectType; }

    /**
     * A new QueryFactory serving this Selector
     * @return   New instance of iQueryFactory
     */
    public iQueryFactory QueryFactory { get { return GetQueryFactory(); } }

    /**
     * A new QueryFactory serving this Selector
     * @return   New instance of iQueryFactory
     */
    public iQueryFactory GetQueryFactory() {
        return new QueryFactory(GetSObjectType(), GetDefaultFields(), GetDefaultOrderBy());
    }

    /**
     * The default SObjectFields.
     * @return   Set<Schema.SObjectField>
     */
    public Set<Schema.SObjectField> DefaultFields { get { return GetDefaultFields(); } }

    /**
     * The default SObjectFields.
     * Must be implemented by the extending class.
     * @return   Set<Schema.SObjectField>
     */
    public abstract Set<Schema.SObjectField> GetDefaultFields();

    /**
     * The OrderBy definitions used by default.
     * @return   List<iOrderBy>
     */
    public List<iOrderBy> DefaultOrderBy { get { return GetDefaultOrderBy(); } }

    /**
     * The OrderBy definitions used by default.
     * Can be overridden by the extending class... implementation can return null.
     * @return   List<iOrderBy>
     */
    public virtual List<iOrderBy> GetDefaultOrderBy() {
        return null;
    }

    /**
     * Retrieves data by matching Id
     * @param  idSet The Id values to match
     * @return       List<SObject>
     */
    public List<SObject> queryById(Set<Id> idSet) {
        Schema.SObjectField field = getFieldFromMap('Id');
        if (field == null) { return new List<SObject>(); }
        return this.QueryFactory
                .WithCriteria(Criteria.ValueIn(field, idSet))
                .Execute();
    }

    /**
     * Retrieves data by matching Name
     * @param  name  The name value to match
     * @return       List<SObject>
     */
    public List<SObject> queryByName(String name) {
        Schema.SObjectField field = getFieldFromMap('Name');
        if (field == null) { return new List<SObject>(); }
        return this.QueryFactory
                .WithCriteria(Criteria.Equals(field, name))
                .Execute();
    }

    /**
     * Retrieves all records for the SObject
     * @return   List<SObject>
     */
    public List<SObject> queryAll() {
        return this.QueryFactory.Execute();
    }

    /**
     * Retrieves all records for the SObject limited to a specified number of rows
     * @param  rowLimit The number of rows to retrieve
     * @return          List<SObject>
     */
    public List<SObject> querySome(Integer rowLimit) {
        return this.QueryFactory.withRowLimit(rowLimit).Execute();
    }

    private Schema.SObjectField getFieldFromMap(String fieldName) {
        for (String key : fieldMap.keySet()) {
            Schema.SObjectField field = fieldMap.get(key);
            if (SchemaHelper.GetDescribe(field).getName() == fieldName) { return field; }
        }
        return null;
    }
}