const BASE = import.meta.env.VITE_API_URL || ''

export async function getPackages({ type, category, search } = {}) {
  const params = new URLSearchParams()
  if (type)     params.set('type', type)
  if (category) params.set('category', category)
  if (search)   params.set('search', search)
  const res = await fetch(`${BASE}/packages?${params}`)
  const data = await res.json()
  return data.packages ?? []
}

export async function getInstalled() {
  const res = await fetch(`${BASE}/installed`)
  const data = await res.json()
  return data.packages ?? []
}

export async function installPackage(id) {
  const res = await fetch(`${BASE}/install/${id}`, { method: 'POST' })
  return res.json()
}

export async function uninstallPackage(id) {
  const res = await fetch(`${BASE}/install/${id}`, { method: 'DELETE' })
  return res.json()
}
