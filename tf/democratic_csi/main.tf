# Nginx ingress
resource "kubernetes_namespace" "democratic_csi" {
  metadata {
    name = "democratic-csi"
  }
}

resource "helm_release" "democratic_csi_iscsi" {
  name       = "democratic-csi"
  repository = "https://democratic-csi.github.io/charts/"
  chart      = "democratic-csi"
  version    = var.democratic_csi_chart_version
  namespace  = kubernetes_namespace.democratic_csi.metadata.0.name

  values = [
<<EOT
# iscsi
csiDriver:
  name: "org.democratic-csi.iscsi"

storageClasses:
- name: truenas-iscsi-csi
  defaultClass: ${var.default_class}
  reclaimPolicy: Delete
  volumeBindingMode: Immediate
  allowVolumeExpansion: true
  parameters:
    fsType: ext4

  mountOptions: []
  secrets:
    provisioner-secret:
    controller-publish-secret:
    node-stage-secret:
    node-publish-secret:
    controller-expand-secret:

driver:
  config:
    driver: freenas-iscsi
    instance_id:
    httpConnection:
      protocol: http
      host: "${var.truenas_host}"
      port: 80
      username: ${var.truenas_user}
      password: "${var.truenas_password}"
      allowInsecure: true
      apiVersion: 2
    sshConnection:
      host: "${var.truenas_host}"
      port: 22
      username: ${var.truenas_user}
      # use either password or key
      privateKey: |
${var.truenas_private_key}

    zfs:
      cli:
        paths:
          zfs: /usr/local/sbin/zfs
          zpool: /usr/local/sbin/zpool
          sudo: /usr/local/bin/sudo
          chroot: /usr/sbin/chroot
      # total volume name (zvol/<datasetParentName>/<pvc name>) length cannot exceed 63 chars
      # https://www.ixsystems.com/documentation/freenas/11.2-U5/storage.html#zfs-zvol-config-opts-tab
      # standard volume naming overhead is 46 chars
      # datasetParentName should therefore be 17 chars or less
      datasetParentName: ${var.iscsi_dataset}/v
      detachedSnapshotsDatasetParentName: ${var.iscsi_dataset}/s
      zvolCompression:
      zvolDedup:
      zvolEnableReservation: false
      zvolBlocksize:
    iscsi:
      targetPortal: "${var.truenas_host}:3260"
      targetPortals: []
      interface:
      namePrefix: csi-
      nameSuffix: "-cluster"
      # add as many as needed
      targetGroups:
        # get the correct ID from the "portal" section in the UI
        - targetGroupPortalGroup: ${var.iscsi_portal_group}
          # get the correct ID from the "initiators" section in the UI
          targetGroupInitiatorGroup: ${var.iscsi_initiator_group}
          # None, CHAP, or CHAP Mutual
          targetGroupAuthType: None
          # get the correct ID from the "Authorized Access" section of the UI
          # only required if using Chap
          targetGroupAuthGroup:
      extentInsecureTpc: true
      extentXenCompat: false
      extentDisablePhysicalBlocksize: true
      extentBlocksize: 4096
      # "" (let FreeNAS decide, currently defaults to SSD), Unknown, SSD, 5400, 7200, 10000, 15000
      extentRpm: "${var.iscsi_extent_rpm}"
      # 0-100 (0 == ignore)
      extentAvailThreshold: 0
EOT
  ]
}
