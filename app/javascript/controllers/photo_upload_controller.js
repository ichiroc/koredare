import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropZone", "fileInput", "uploadPrompt", "imagePreview", "previewImg", "changeImageBtn"]

  connect() {
    this.setupEventListeners()
  }

  setupEventListeners() {
    this.dropZoneTarget.addEventListener('click', this.handleClick.bind(this))
    this.fileInputTarget.addEventListener('change', this.handleFileSelect.bind(this))
    this.changeImageBtnTarget.addEventListener('click', this.handleChangeImage.bind(this))
    this.dropZoneTarget.addEventListener('dragover', this.handleDragOver.bind(this))
    this.dropZoneTarget.addEventListener('dragleave', this.handleDragLeave.bind(this))
    this.dropZoneTarget.addEventListener('drop', this.handleDrop.bind(this))
  }

  handleClick(e) {
    if (e.target !== this.changeImageBtnTarget) {
      this.fileInputTarget.click()
    }
  }

  handleFileSelect(e) {
    this.handleFile(e.target.files[0])
  }

  handleChangeImage(e) {
    e.stopPropagation()
    this.fileInputTarget.click()
  }

  handleDragOver(e) {
    e.preventDefault()
    this.dropZoneTarget.classList.add('bg-primary', 'bg-opacity-10')
  }

  handleDragLeave(e) {
    e.preventDefault()
    this.dropZoneTarget.classList.remove('bg-primary', 'bg-opacity-10')
  }

  handleDrop(e) {
    e.preventDefault()
    this.dropZoneTarget.classList.remove('bg-primary', 'bg-opacity-10')

    const file = e.dataTransfer.files[0]
    if (file && file.type.startsWith('image/')) {
      this.fileInputTarget.files = e.dataTransfer.files
      this.handleFile(file)
    }
  }

  handleFile(file) {
    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        this.previewImgTarget.src = e.target.result
        this.uploadPromptTarget.classList.add('hidden')
        this.imagePreviewTarget.classList.remove('hidden')
      }
      reader.readAsDataURL(file)
    }
  }
}
