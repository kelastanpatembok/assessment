use bigdecimal::BigDecimal;
use serde::{Deserialize, Deserializer, Serialize, Serializer};
use serde_json::Number;

/// BigDecimal that serializes as a JSON number (not a string), matching how
/// Jackson serializes java.math.BigDecimal. Deserialization accepts both a
/// JSON number and a JSON string (the frontend sometimes sends numbers).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Decimal(pub BigDecimal);

impl Decimal {
    pub fn zero() -> Self {
        Decimal(BigDecimal::from(0))
    }
    pub fn from_f64(v: f64) -> Self {
        let s = format!("{}", v);
        Decimal(s.parse::<BigDecimal>().unwrap_or_else(|_| BigDecimal::from(0)))
    }
    pub fn to_f64(&self) -> f64 {
        self.0.to_string().parse().unwrap_or(0.0)
    }
}

impl Serialize for Decimal {
    fn serialize<S: Serializer>(&self, serializer: S) -> Result<S::Ok, S::Error> {
        let n: Number = serde_json::from_str(&self.0.to_string()).map_err(serde::ser::Error::custom)?;
        n.serialize(serializer)
    }
}

impl<'de> Deserialize<'de> for Decimal {
    fn deserialize<D: Deserializer<'de>>(d: D) -> Result<Self, D::Error> {
        let v = serde_json::Value::deserialize(d)?;
        match v {
            serde_json::Value::Number(n) => n
                .to_string()
                .parse::<BigDecimal>()
                .map(Decimal)
                .map_err(serde::de::Error::custom),
            serde_json::Value::String(s) => s
                .parse::<BigDecimal>()
                .map(Decimal)
                .map_err(serde::de::Error::custom),
            _ => Err(serde::de::Error::custom("expected a number or numeric string")),
        }
    }
}

impl From<BigDecimal> for Decimal {
    fn from(b: BigDecimal) -> Self {
        Decimal(b)
    }
}

/// sqlx decodes PostgreSQL NUMERIC directly into bigdecimal::BigDecimal; map
/// that through our wrapper so FromRow-based row structs work unchanged.
impl<'r> sqlx::Decode<'r, sqlx::Postgres> for Decimal {
    fn decode(
        value: sqlx::postgres::PgValueRef<'r>,
    ) -> Result<Self, Box<dyn std::error::Error + 'static + Send + Sync>> {
        let b = BigDecimal::decode(value)?;
        Ok(Decimal(b))
    }
}

impl sqlx::Type<sqlx::Postgres> for Decimal {
    fn type_info() -> sqlx::postgres::PgTypeInfo {
        <BigDecimal as sqlx::Type<sqlx::Postgres>>::type_info()
    }
}

impl sqlx::Encode<'_, sqlx::Postgres> for Decimal {
    fn encode_by_ref(&self, buf: &mut sqlx::postgres::PgArgumentBuffer) -> Result<sqlx::encode::IsNull, Box<dyn std::error::Error + 'static + Send + Sync>> {
        self.0.clone().encode(buf)
    }
}
